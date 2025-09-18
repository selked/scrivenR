#' Transcribe 16-bit Mono .WAV file
#'
#' This function takes a list of file names for 16-bit mono WAVs and applies batch processing of automatic transcription using Whisper.
#' @param x Output of list.files() in working directory containing videos
#' @param include_timing Option to include timestamps for each line of text, default=TRUE
#' @param internal_convert Option to retain naming format for conversions made with this package, default=TRUE
#' @param all_cores Use all available CPU cores for parallel processing (otherwise, half will be used), default=FALSE
#' @keywords transcription, whisper, ASR, batch-processing
#' @export
#' @examples
#' transcribe_audio(list.files(), include_timing=TRUE, internal_convert=TRUE)


transcribe_audio <- function(x, model_path, include_timing=FALSE, internal_convert=TRUE, all_cores = FALSE) {

if (missing(model_path)) {
  stop("Path to Whisper acoustic model must be specified. Enter the directory containing the model downloaded with audio.whisper, or use its whisper() function to download one of the acoustic models and enter that path here.")
}
  else {

n_cores <- as.numeric(detectCores())

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
    stop("No recognizable audio files in working directory. Your files must be 16-bit mono .WAVs. Assure you are in the directory containing your files. If so, use extract_audio() or convert_audio() to resolve file-format requirements.")
  }

  else {

  for (fn in audio_files) {

    print(paste0("Transcribing ", fn, "..."))

    if (all_cores == TRUE) {

    tic()
    trans <- predict(model,
                     newdata = fn,
                     language = "en",
                     n_threads = n_cores)
    toc()

    print(paste0("Finished transcribing ", fn, "."))
}

    else {

      tic()
      trans <- predict(model,
                       newdata = fn,
                       language = "en",
                       n_threads = ceiling((n_cores/2)))
      toc()

      print(paste0("Finished transcribing ", fn, "."))
    }


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
