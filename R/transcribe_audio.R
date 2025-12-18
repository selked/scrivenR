#' Transcribe 16-bit Mono .WAV file
#'
#' This function takes a list of file names for 16-bit mono WAVs and applies batch processing of automatic transcription using Whisper.
#' @param x Output of list.files() in working directory containing audio
#' @param model_path A character string of the path for your local Whisper acoustic model; this is required
#' @param include_timing Option to include timestamps for each line of text, default=TRUE
#' @param internal_convert Option to retain naming format for conversions made with this package, default=TRUE. Setting to FALSE will point the function at any .WAVs in the working directory.
#' @param write_textgrids Option to print time-aligned .TextGrid files for use in Praat; FALSE by default
#' @param n_threads The number of CPU threads to be used in parallel processing. Default value is 1, i.e. single-thread processing.
#' @keywords transcription, whisper, ASR, batch-processing
#' @export
#' @examples
#' transcribe_audio(list.files(), model_path = mp, include_timing=TRUE, internal_convert=TRUE, write_textgrids = FALSE, all_cores = FALSE)


transcribe_audio <- function(x, model_path, include_timing = FALSE, internal_convert = TRUE, write_textgrids = FALSE, n_threads = 1) {

if (missing(model_path)) {
  stop("Path to Whisper acoustic model must be specified. Enter the directory containing the model downloaded with audio.whisper, or use its whisper() function to download one of the acoustic models and enter that path here.")
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
    stop("No recognizable audio files in working directory. Your files must be 16-bit mono .WAVs. Assure you are in the directory containing your files. If so, use extract_audio() or convert_audio() to resolve file-format requirements.")
  }

  else {

  for (fn in audio_files) {

    message(paste0("Transcribing ", fn, "..."))


      start_time <- now()
      trans <- predict(model,
                       newdata = fn,
                       language = "en",
                       n_threads = n_threads
                       )
      end_time <- now()
      message(paste0("Finished transcribing ", fn, "."))
      message(sprintf(
        "Transcription completed in %.5f %s",
        end_time - start_time,
        units(difftime(end_time, start_time))
      )
      )



    speech <- trans$data |>
      select(text)

    if (include_timing==TRUE) {
      message(paste0("Writing timed transcript for ", fn, "..."))

      write_delim(trans$data, paste0(file_path_sans_ext(fn), "_timed_transcript.txt"), delim = "\t")
    }

    else {
      message(paste0("Writing text-only transcript for ", fn, "..."))

      write_delim(speech, paste0(file_path_sans_ext(fn), "_transcript.txt"), delim = "\t")


    }

    if (write_textgrids == TRUE) {
      message(paste0("Writing Praat TextGrid for ", fn, "..."))

      chk <- trans$data

      names(chk)[4] <- "content"

      chk$content <- gsub("\"", "", chk$content, fixed = TRUE)
      chk$content <- gsub("^$-", "", chk$content)
      chk$content <- gsub("^ -", "", chk$content)

      chk <- chk |>
        mutate(time_start = period_to_seconds(hms(from))) |>
        mutate(time_end = period_to_seconds(hms(to))) |>
        select(content, time_start, time_end)

      dur <- get_sound_duration(fn)
      dur <- dur[1,2]

      create_empty_textgrid(
        duration = dur+10,
        point_tier = NULL,
        path = getwd(),
        result_file_name = paste0(file_path_sans_ext(fn))
      )

      text_grids <- list.files()

      text_grids <- text_grids |>
        str_subset(paste0(file_path_sans_ext(fn), ".TextGrid$"))

      for (tg in text_grids) {

      df_to_tier(
        chk,
        textgrid = tg,
        tier_name = "Speaker 1",
        overwrite = TRUE)

      }
    }

    }
    message(paste0("Transcription(s) complete. Output located in ", getwd()))
  }
}

}
