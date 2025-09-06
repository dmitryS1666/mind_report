class AudioTranscriber
  def initialize(analysis)
    @analysis = analysis
  end

  def call
    file = @analysis.audio.blob.open { |f| f }
    resp = OPENAI_CLIENT.audio.transcriptions.create(
      file: file.path,
      model: ENV.fetch("OPENAI_TRANSCRIPTION_MODEL", "whisper-1")
    )
    resp["text"].to_s
  end
end
