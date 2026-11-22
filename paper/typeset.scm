;; Typeset a document headless: export it to PDF (which typesets), generate
;; the auxiliary data (references, bibliography), export again, and save the
;; document with its references. Exports overwrite: headless TeXmacs would
;; otherwise ask, nobody answers, and the export is skipped.
(define (paper-typeset in pdf)
  (let ((u (string->url in)))
    (style-clear-cache)
    (load-buffer u)
    (switch-to-buffer u)
    (export-buffer-main u (string->url pdf) "pdf" (list :overwrite))
    (generate-all-aux)
    (update-current-buffer)
    (export-buffer-main u (string->url pdf) "pdf" (list :overwrite))
    (buffer-pretend-modified u)
    (buffer-save u)))
