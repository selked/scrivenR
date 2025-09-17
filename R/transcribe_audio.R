#' Transcribe 16-bit Mono .WAV file
#'
#' This function takes a list of files, filters by common audio file extensions, and then runs an ffmpeg command to convert the audio and write output to the working directory.
#' @param x Output of list.files() in working directory containing videos
#' @param include_timing Option to include timestamps for each line of text, default=TRUE
#' @param internal_convert Option to retain naming format for conversions made with this package, default=TRUE
#' @keywords transcription, whisper, ASR, batch-processing
#' @export
#' @examples
#' transcribe_audio(list.files(), include_timing=TRUE, internal_convert=TRUE)


transcribe_audio <- function(x, include_timing=TRUE, internal_convert=TRUE, model_path) {

if (missing(model_path)) {
  print("Path to Whisper acoustic model must be specified. Enter the directory containing the model downloaded with audio.whisper, or use its whisper() function to download one of the acoustic models and enter that path here.")
}
  else {

model <- whisper(model_path)

if (internal_convert==TRUE) {
  audio_files <- x |>
    str_subset("_converted.wav$")
}
  else {
    audio_files <- x |>
      str_subset(".wav$")
}


  if (length(audio_files)==0) {
    print("No recognizable audio files in working directory. Your files must be 16-bit mono .WAVs. Assure you are in the directory containing your files. If so, use extract_audio() or convert_audio() to resolve file-format requirements.")
  }

  else {

  for (fn in audio_files) {

    print(paste0("Transcribing ", fn, "..."))

    tic()
    trans <- predict(model,
                     newdata = fn,
                     language = "en",
                     n_threads = 8)
    toc()

    print(paste0("Finished transcribing ", fn, "."))

    speech <- trans$data |>
      select(text)

    if (include_timing==TRUE) {
      print(paste0("Writing timed transcript for ", fn, "..."))

      write_delim(trans$data, paste0(str_extract(fn, "^[:graph:]{5}"), "_timed_transcript.txt"), delim = "\t")
    }

    else {
      print(paste0("Writing text-only transcript for ", fn, "..."))

      write_delim(speech, paste0(str_extract(fn, "^[:graph:]{5}"), "_transcript.txt"), delim = "\t")


    }
    print(paste0("Transcription(s) complete. Output located in ", getwd()))
   }
  }
}

}
