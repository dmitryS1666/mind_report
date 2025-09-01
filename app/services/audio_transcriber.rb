class AudioTranscriber
  def initialize(analysis)
    @analysis = analysis
  end

  def call
    file = @analysis.audio.blob.open { |f| f } # Tempfile
    # Whisper (стабильно и дёшево)
    resp = OPENAI_CLIENT.audio.transcriptions.create(
      file: file.path,
      model: "whisper-1"
    )
    resp["text"].to_s
  end
end
