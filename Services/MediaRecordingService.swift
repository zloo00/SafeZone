import Foundation
import AVFoundation
import Combine

class MediaRecordingService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioPermissionGranted = false
    @Published var videoPermissionGranted = false
    
    private var audioRecorder: AVAudioRecorder?
    private var videoCaptureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var recordingTimer: Timer?
    
    private var audioRecordingURL: URL?
    private var videoRecordingURL: URL?
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    // MARK: - Permissions
    
    func checkPermissions() {
        checkAudioPermission()
        checkVideoPermission()
    }
    
    private func checkAudioPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.audioPermissionGranted = granted
            }
        }
    }
    
    private func checkVideoPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            videoPermissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.videoPermissionGranted = granted
                }
            }
        default:
            videoPermissionGranted = false
        }
    }
    
    // MARK: - Audio Recording
    
    func startAudioRecording() {
        guard audioPermissionGranted else {
            print("Нет разрешения на запись аудио")
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            audioRecordingURL = documentsPath.appendingPathComponent("emergency_audio_\(Date().timeIntervalSince1970).m4a")
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioRecordingURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            startRecordingTimer()
            
            print("Начата запись аудио")
        } catch {
            print("Ошибка начала записи аудио: \(error)")
        }
    }
    
    func stopAudioRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Ошибка остановки аудиосессии: \(error)")
        }
        
        stopRecordingTimer()
        isRecording = false
        recordingDuration = 0
        
        print("Остановлена запись аудио")
    }
    
    // MARK: - Video Recording
    
    func startVideoRecording() {
        guard videoPermissionGranted else {
            print("Нет разрешения на запись видео")
            return
        }
        
        setupVideoCapture()
        
        guard let videoOutput = videoOutput else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        videoRecordingURL = documentsPath.appendingPathComponent("emergency_video_\(Date().timeIntervalSince1970).mov")
        
        videoOutput.startRecording(to: videoRecordingURL!, recordingDelegate: self)
        
        isRecording = true
        startRecordingTimer()
        
        print("Начата запись видео")
    }
    
    func stopVideoRecording() {
        videoOutput?.stopRecording()
        videoCaptureSession?.stopRunning()
        
        stopRecordingTimer()
        isRecording = false
        recordingDuration = 0
        
        print("Остановлена запись видео")
    }
    
    private func setupVideoCapture() {
        videoCaptureSession = AVCaptureSession()
        videoOutput = AVCaptureMovieFileOutput()
        
        guard let session = videoCaptureSession,
              let output = videoOutput else { return }
        
        session.beginConfiguration()
        
        // Добавляем видеовход
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Не удалось настроить видеовход")
            return
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        
        // Добавляем аудиовход
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {
            print("Не удалось настроить аудиовход")
            return
        }
        
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        // Добавляем видеовыход
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    // MARK: - Timer
    
    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordingDuration += 1.0
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    // MARK: - Emergency Recording
    
    func startEmergencyRecording() {
        startAudioRecording()
        startVideoRecording()
    }
    
    func stopEmergencyRecording() {
        stopAudioRecording()
        stopVideoRecording()
    }
    
    // MARK: - File Management
    
    func getRecordingFiles() -> [URL] {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            return files.filter { $0.pathExtension == "m4a" || $0.pathExtension == "mov" }
        } catch {
            print("Ошибка получения файлов записей: \(error)")
            return []
        }
    }
    
    func deleteRecordingFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("Файл удален: \(url.lastPathComponent)")
        } catch {
            print("Ошибка удаления файла: \(error)")
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension MediaRecordingService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Аудиозапись завершена успешно")
        } else {
            print("Ошибка аудиозаписи")
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension MediaRecordingService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Ошибка видеозаписи: \(error)")
        } else {
            print("Видеозапись завершена успешно")
        }
    }
} 