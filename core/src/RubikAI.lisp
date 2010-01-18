;; Christopher Jackson
;; December, 2009
;; RubikAI.lisp
;; output files *.rbk may be imported into RubikAI GUI front-end (Qt)

(defparameter *goal-cube* '(
((red red red) (red red red) (red red red))
((blue blue blue) (blue blue blue) (blue blue blue))
((orange orange orange) (orange orange orange) (orange orange orange))
((green green green) (green green green) (green green green))
((yellow yellow yellow) (yellow yellow yellow) (yellow yellow yellow))
((white white white) (white white white) (white white white))))

(defparameter *read-only* nil)

;; A node has 4 important parameters ((cube face direction) #conflilcts)

(defparameter *node* nil)

(defparameter *rotations* '(
(rotate-cube 'front 'clockwise)
(rotate-cube 'front 'counter-clockwise)
(rotate-cube 'left 'clockwise)
(rotate-cube 'left 'counter-clockwise)
(rotate-cube 'back 'clockwise)
(rotate-cube 'back 'counter-clockwise)
(rotate-cube 'right 'clockwise)
(rotate-cube 'right 'counter-clockwise)
(rotate-cube 'top 'clockwise)
(rotate-cube 'top 'counter-clockwise)
(rotate-cube 'bottom 'clockwise)
(rotate-cube 'bottom 'counter-clockwise)))

(defun simulate (&key (infile nil) (outfile "rubik-out.rbk")
		 (algorithm #'simulated-annealing)
		 (successor #'novice-successor))
  (let* ((filestream (open outfile :direction :output :if-exists :supersede))
	 (log (log-gen :filestream filestream)) ;; use like (funcall log <node>)
	 (strategy #'(lambda () (funcall algorithm successor log)))
	 (trials 0) (best-trial 0)
	 (best nil))
    ;; setup cube based on default-cube or infile
    (cond ((not (null infile))
	   	(cube-from-file infile))
	  (t
	   (setf *node* (copy-tree *goal-cube*))
	   (setf *node* (list (list *node*  nil nil) (conflicts *node*)))
	   (setf *node* (randomize-cube :iterations 5))))
    (format t "INITIAL STATE: ~%~a~%" *node*)
    ;; check for null/invalid cube
    (when (null *node*)
      (format t "Invalid cube in file:~a~%" infile)
      (return-from simulate))

    ;; if we get here, we have a good initial cube state
    ;; gete the best cube state
    (multiple-value-setq (best trials best-trial) (funcall strategy))
    ;(multiple-value-setq (best trials best-trial) (simulated-annealing log))
    ;(multiple-value-setq (best trials best-trial) (greedy log))
    (close filestream)
    (format t "After ~a iterations my best is (~a conflicts in ~a trials):~%~%~a~%" 
	    trials (second best) best-trial (first (first best)))))

(defun simulated-annealing (successor log)
  (let ((best *node*)
	(schedule (make-scheduler :a 20 :variant .005 :max-time 50))
	(next nil)
	(temp 0)
	(delta 0)
	(trials 0) (best-trial 0))
    ;; forever loop, but we expect to return best when temp has cooled to zero
    (do ((time 1 (1+ time))) (())
      (setf trials (1+ trials))
      (funcall log *node*)
      (setf temp (funcall schedule time))
      (when (goal-test *node*)
	(return-from simulated-annealing (values *node* trials best-trial)))
      (when (= temp 0.0)
	(return-from simulated-annealing (values best trials best-trial)))
      (when (< (second *node*) (second best))
	(setf best *node*)
	(setf best-trial trials))
      (setf *read-only* t)
      (setf next (if (eq successor #'smart-successor) 
		     (funcall successor *node*) (funcall successor)))
      (setf *read-only* nil)
      (setf delta (- (second next) (second *node*)))
      (when (or (< delta 0.0) (< (random 1.0) (exp (/ (- delta) temp))))
	(setf *node* next)))))

(defun greedy (successor log)
  (let ((best *node*)
	(next nil)
	(delta 0)
	(trials 0) (best-trial 0))
    ;; forever loop, but we expect to return best when temp has cooled to zero
    (do ((time 1 (1+ time))) (())
      (setf trials (1+ trials))
      (funcall log *node*)
      (when (goal-test *node*)
	(return-from greedy (values *node* trials best-trial)))
      (when (= time 50)
	(return-from greedy (values best trials best-trial)))
      (when (< (second *node*) (second best))
	(setf best *node*)
	(setf best-trial trials))
      (setf *read-only* t)
      (setf next (if (eq successor #'smart-successor) 
		     (funcall successor *node*) (funcall successor)))
      (setf *read-only* nil)
      (setf delta (- (second next) (second *node*)))
      (when (< delta 0.0)
	(setf *node* next)))))

(defun goal-test (node)
  (if (null (second node))
    nil
    (= 0 (second node))))

(defun random-successor ()
  ;; make 1 random move and return a node,i.e. (cube #conflicts)
  (randomize-cube :iterations 1))

(defun novice-successor ()
  (let ((best-successor (copy-tree *node*)) (next nil))
    (do ((move *rotations* (rest move)))
	((null move) best-successor)
      (setf next (eval (first move)))
      (when (< (second next) (second best-successor))
	(setf best-successor next)))))

(defun smart-successor (successor &key (depth 5))
  (let ((best-successor (copy-tree successor)) (next nil))
    (if (= 0 depth)
	best-successor
	(progn
	    (do ((move *rotations* (rest move)))
		((null move) best-successor)
	      (smart-successor best-successor :depth (- depth 1))
	      (setf next (eval (first move)))
	      (when (< (second next) (second best-successor))
		(setf best-successor next)))))))

(defun randomize-cube (&key (iterations 12)) ; returns a node
  (if (= iterations 1) ; do last iteration and return its value
      (eval (elt *rotations* (random (length *rotations*))))
      (progn ; otherwise recursively perform random rotations counting down iterations
       (eval (elt *rotations* (random (length *rotations*))))
       (randomize-cube :iterations (- iterations 1)))))
  
(defun conflicts (cube)
  ;; sides go (front red) (left blue) (back orange) (right green) (top yellow) (bottom white)
  (+
   (side-conflicts (first cube) 'red)
   (side-conflicts (second cube) 'blue)
   (side-conflicts (third cube) 'orange)
   (side-conflicts (fourth cube) 'green)
   (side-conflicts (fifth cube) 'yellow)
   (side-conflicts (sixth cube) 'white)))

(defun side-conflicts (side color)
  ;; Count the conflicts only on the side given
  (let ((num-conflicts 0))
    (dolist (row side)
      (dolist (col row)
	(if (not (eq col color))
	    (setf num-conflicts (1+ num-conflicts)))))
    num-conflicts))

(defun log-gen (&key (filestream))
  #'(lambda (node) (logwrite filestream node)))

(defun logwrite (filestream node)
  ;; Output the move and state of cube to the filestream
  (let ((face (second (first node)))
	(direction (third (first node))))
    ;; face direction (convert to lowercase using ~( ~) directive)
    (format filestream "~(~a~) ~(~a~)~%" face direction)
    ;; output the cube in order (front left back right top bottom)
    (do ((cube (first (first node)) (rest cube))
	 (side '("frontface" "leftface" 
		 "backface" "rightface" 
		 "topface" "bottomface") (rest side)))
	((null cube))
      (format filestream "~a" (car side))
      (dolist (row (car cube))
	(dolist (col row)
	  (format filestream " ~(~a~)" col))) 
      (format filestream "~%"))
    (format filestream "~%")))

(defun cube-from-file (infile))

(defun make-scheduler (&key (a 20) (variant 0.005) (max-time 500))
  ;; Return a scheduler which uses an exponential function with a max time
  #'(lambda (time) (if (< time max-time)
		       (* a (exp (- (* variant time))))
		       0)))

(defun rotate-cube (face direction) ; returns a node
  (let ((temp-face nil)
	(temp-border-front nil)
	(temp-border-left nil)
	(temp-border-back nil)
	(temp-border-right nil)
	(temp-border-top nil)
	(temp-border-bottom nil)
	(cube (if (null *read-only*)
		  (first (first *node*))
		  (copy-tree (first (first *node*))))))
  (cond 
    ((and (eq face 'front) (eq direction 'clockwise)) 
     (setf temp-face (copy-tree (nth 0 cube)))
     ; order: top right bottom left
     (setf temp-border-top (rotate-border 'front 'top cube))
     (setf temp-border-right (rotate-border 'front 'right cube))
     (setf temp-border-bottom (rotate-border 'front 'bottom cube))
     (setf temp-border-left (rotate-border 'front 'left cube))

     ; first set the new face values
     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 0 cube) i) j) (elt (elt temp-face (- 2 j)) i))))
     
     ; now set the new borders
     ; order top->left right->top bottom->right left->bottom
     (rotate-border 'front 'top cube :set-list (copy-list temp-border-left))
     (rotate-border 'front 'right cube :set-list (copy-list temp-border-top))
     (rotate-border 'front 'bottom cube :set-list (copy-list temp-border-right))
     (rotate-border 'front 'left cube :set-list (copy-list temp-border-bottom)))

    ((and (eq face 'front) (eq direction 'counter-clockwise))
     (setf temp-face (copy-tree (nth 0 cube)))
     ; order: top left bottom right
     (setf temp-border-top (rotate-border 'front 'top cube))
     (setf temp-border-left (rotate-border 'front 'left cube))
     (setf temp-border-bottom (rotate-border 'front 'bottom cube))
     (setf temp-border-right (rotate-border 'front 'right cube))

     ; first set the new face values
     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 0 cube) i) j) (elt (elt temp-face j) (- 2 i)))))

     ; now set the new borders
     ; order: top->right left->top bottom->left right->bottom
     (rotate-border 'front 'top cube :set-list (copy-list temp-border-right))
     (rotate-border 'front 'left cube :set-list (copy-list temp-border-top))
     (rotate-border 'front 'bottom cube :set-list (copy-list temp-border-left))
     (rotate-border 'front 'right cube :set-list (copy-list temp-border-bottom)))


    ((and (eq face 'left) (eq direction 'clockwise))
     (setf temp-face (copy-tree (nth 1 cube)))
     ; order: top front bottom back
     (setf temp-border-top (rotate-border 'left 'top cube))
     (setf temp-border-front (rotate-border 'left 'front cube))
     (setf temp-border-bottom (rotate-border 'left 'bottom cube))
     (setf temp-border-back (rotate-border 'left 'back cube))

     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 1 cube) i) j) (elt (elt temp-face (- 2 j)) i))))

     ; order: top->back front->top bottom->front back->bottom
     (rotate-border 'left 'top cube :set-list (copy-list temp-border-back))
     (rotate-border 'left 'front cube :set-list (copy-list temp-border-top))
     (rotate-border 'left 'bottom cube :set-list (copy-list temp-border-front))
     (rotate-border 'left 'back cube :set-list (copy-list temp-border-bottom)))

    ((and (eq face 'left) (eq direction 'counter-clockwise))
     (setf temp-face (copy-tree (nth 1 cube)))
     ; order: top back bottom front
     (setf temp-border-top (rotate-border 'left 'top cube))
     (setf temp-border-back (rotate-border 'left 'back cube))
     (setf temp-border-bottom (rotate-border 'left 'bottom cube))
     (setf temp-border-front (rotate-border 'left 'front cube))

     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 1 cube) i) j) (elt (elt temp-face j) (- 2 i)))))

     ; order: top->front back->top bottom->back front->bottom
     (rotate-border 'left 'top cube :set-list (copy-list temp-border-front))
     (rotate-border 'left 'back cube :set-list (copy-list temp-border-top))
     (rotate-border 'left 'bottom cube :set-list (copy-list temp-border-back))
     (rotate-border 'left 'front cube :set-list (copy-list temp-border-bottom)))


    ((and (eq face 'back) (eq direction 'clockwise))
     (setf temp-face (copy-tree (nth 2 cube)))
     ; order: top left bottom right
     (setf temp-border-top (rotate-border 'back 'top cube))
     (setf temp-border-left (rotate-border 'back 'left cube))
     (setf temp-border-bottom (rotate-border 'back 'bottom cube))
     (setf temp-border-right (rotate-border 'back 'right cube))

     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 2 cube) i) j) (elt (elt temp-face (- 2 j)) i))))

     ; order: top->right left->top bottom->left right->bottom
     (rotate-border 'back 'top cube :set-list (copy-list temp-border-right))
     (rotate-border 'back 'left cube :set-list (copy-list temp-border-top))
     (rotate-border 'back 'bottom cube :set-list (copy-list temp-border-left))
     (rotate-border 'back 'right cube :set-list (copy-list temp-border-bottom)))

    ((and (eq face 'back) (eq direction 'counter-clockwise))
     (setf temp-face (copy-tree (nth 2 cube)))
     ; order top right bottom left
     (setf temp-border-top (rotate-border 'back 'top cube))
     (setf temp-border-right (rotate-border 'back 'right cube))
     (setf temp-border-bottom (rotate-border 'back 'bottom cube))
     (setf temp-border-left (rotate-border 'back 'left cube))

     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 2 cube) i) j) (elt (elt temp-face j) (- 2 i)))))

     ; order: top->left right->top bottom->right left->bottom
     (rotate-border 'back 'top cube :set-list (copy-list temp-border-left))
     (rotate-border 'back 'right cube :set-list (copy-list temp-border-top))
     (rotate-border 'back 'bottom cube :set-list (copy-list temp-border-right))
     (rotate-border 'back 'left cube :set-list (copy-list temp-border-bottom)))


    ((and (eq face 'right) (eq direction 'clockwise))
     (setf temp-face (copy-tree (nth 3 cube)))
     ; order: top back bottom front
     (setf temp-border-top (rotate-border 'right 'top cube))
     (setf temp-border-back (rotate-border 'right 'back cube))
     (setf temp-border-bottom (rotate-border 'right 'bottom cube))
     (setf temp-border-front (rotate-border 'right 'front cube))

     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 3 cube) i) j) (elt (elt temp-face (- 2 j)) i))))

     ; order: top->front back->top bottom->back front->bottom
     (rotate-border 'right 'top cube :set-list (copy-list temp-border-front))
     (rotate-border 'right 'back cube :set-list (copy-list temp-border-top))
     (rotate-border 'right 'bottom cube :set-list (copy-list temp-border-back))
     (rotate-border 'right 'front cube :set-list (copy-list temp-border-bottom)))

    ((and (eq face 'right) (eq direction 'counter-clockwise))
     (setf temp-face (copy-tree (nth 3 cube)))
     ; order: top front bottom back
     (setf temp-border-top (rotate-border 'right 'top cube))
     (setf temp-border-front (rotate-border 'right 'front cube))
     (setf temp-border-bottom (rotate-border 'right 'bottom cube))
     (setf temp-border-back (rotate-border 'right 'back cube))

     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 3 cube) i) j) (elt (elt temp-face j) (- 2 i)))))

     ; order: top->back front->top bottom->front back->bottom
     (rotate-border 'right 'top cube :set-list (copy-list temp-border-back))
     (rotate-border 'right 'front cube :set-list (copy-list temp-border-top))
     (rotate-border 'right 'bottom cube :set-list (copy-list temp-border-front))
     (rotate-border 'right 'back cube :set-list (copy-list temp-border-bottom)))


    ((and (eq face 'top) (eq direction 'clockwise))
     (setf temp-face (copy-tree (nth 4 cube)))
     ; order: back right front left
     (setf temp-border-back (rotate-border 'top 'back cube))
     (setf temp-border-right (rotate-border 'top 'right cube))
     (setf temp-border-front (rotate-border 'top 'front cube))
     (setf temp-border-left (rotate-border 'top 'left cube))

     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 4 cube) i) j) (elt (elt temp-face (- 2 j)) i))))

     ; order: back->left right->back front->right left->front
     (rotate-border 'top 'back cube :set-list (copy-list temp-border-left))
     (rotate-border 'top 'right cube :set-list (copy-list temp-border-back))
     (rotate-border 'top 'front cube :set-list (copy-list temp-border-right))
     (rotate-border 'top 'left cube :set-list (copy-list temp-border-front)))

    ((and (eq face 'top) (eq direction 'counter-clockwise))
     (setf temp-face (copy-tree (nth 4 cube)))
     ; order: back left front right
     (setf temp-border-back (rotate-border 'top 'back cube))
     (setf temp-border-left (rotate-border 'top 'left cube))
     (setf temp-border-front (rotate-border 'top 'front cube))
     (setf temp-border-right (rotate-border 'top 'right cube))

     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 4 cube) i) j) (elt (elt temp-face j) (- 2 i)))))

     ; order: back->right left->back front->left right->front
     (rotate-border 'top 'back cube :set-list (copy-list temp-border-right))
     (rotate-border 'top 'left cube :set-list (copy-list temp-border-back))
     (rotate-border 'top 'front cube :set-list (copy-list temp-border-left))
     (rotate-border 'top 'right cube :set-list (copy-list temp-border-front)))


    ((and (eq face 'bottom)(eq direction 'clockwise))
     (setf temp-face (copy-tree (nth 5 cube)))
     ; order: front right back left
     (setf temp-border-front (rotate-border 'bottom 'front cube))
     (setf temp-border-right (rotate-border 'bottom 'right cube))
     (setf temp-border-back (rotate-border 'bottom 'back cube))
     (setf temp-border-left (rotate-border 'bottom 'left cube))

     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 5 cube) i) j) (elt (elt temp-face (- 2 j)) i))))

     ; order: front->left right->front back->right left->back
     (rotate-border 'bottom 'front cube :set-list (copy-list temp-border-left))
     (rotate-border 'bottom 'right cube :set-list (copy-list temp-border-front))
     (rotate-border 'bottom 'back cube :set-list (copy-list temp-border-right))
     (rotate-border 'bottom 'left cube :set-list (copy-list temp-border-back)))

    ((and (eq face 'bottom)(eq direction 'counter-clockwise))
     (setf temp-face (copy-tree (nth 5 cube)))
     ; order: front left back right
     (setf temp-border-front (rotate-border 'bottom 'front cube))
     (setf temp-border-left (rotate-border 'bottom 'left cube))
     (setf temp-border-back (rotate-border 'bottom 'back cube))
     (setf temp-border-right (rotate-border 'bottom 'right cube))

     (dotimes (i 3)
       (dotimes (j 3)
	 (setf (elt (elt (nth 5 cube) i) j) (elt (elt temp-face j) (- 2 i)))))

     ; order: front->right left->front back->left right->back
     (rotate-border 'bottom 'front cube :set-list (copy-list temp-border-right))
     (rotate-border 'bottom 'left cube :set-list (copy-list temp-border-front))
     (rotate-border 'bottom 'back cube :set-list (copy-list temp-border-left))
     (rotate-border 'bottom 'right cube :set-list (copy-list temp-border-back)))

    (t nil))
  (list (list cube face direction) (conflicts cube))))


; Rotate-border logic perspective of <face> and changing <side>
(defun rotate-border (face side cube &key (set-list nil))
  (cond 
    ((eq face 'front) ; order: top right bottom left
     (cond 
       ((eq side 'top)
	(if (null set-list)
	    (copy-list (first (last (nth 4 cube))))
	    (setf (first (last (nth 4 cube))) set-list)))
       ((eq side 'right)
	(if (null set-list)
	    (copy-list (map 'list #'(lambda (x) (first x)) (nth 3 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 3 cube) i) 0) (elt set-list i)))))
       ((eq side 'bottom)
	(if (null set-list)
	    (copy-list (first (nth 5 cube)))
	    (setf (first (nth 5 cube)) set-list)))
       ((eq side 'left) 
	(if (null set-list)
	    (copy-list (map 'list #'(lambda (x) (first (last x))) (nth 1 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 1 cube) i) 2) (elt set-list i)))))
       (t nil)))
    ((eq face 'left) ; order: top front bottom back
     (cond 
       ((eq side 'top)
	(if (null set-list)
	    (copy-list(map 'list #'(lambda (x) (first x)) (nth 4 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 4 cube) i) 0) (elt set-list i)))))
       ((eq side 'front) 
	(if (null set-list)
	    (copy-list (map 'list #'(lambda (x) (first x)) (nth 0 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 0 cube) i) 0) (elt set-list i)))))
       ((eq side 'bottom)
	(if (null set-list)
	    (copy-list (map 'list #'(lambda (x) (first x)) (nth 5 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 5 cube) i) 0) (elt set-list i)))))
       ((eq side 'back)
	(if (null set-list)
	    (copy-list (map 'list #'(lambda (x) (first (last x))) (nth 2 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 2 cube) i) 2) (elt set-list i)))))
       (t nil)))
    ((eq face 'back) ; order: top left bottom right
     (cond 
       ((eq side 'top)
	(if (null set-list)
	    (copy-list (first (nth 4 cube)))
	    (setf (first (nth 4 cube)) set-list)))
       ((eq side 'left) 
	(if (null set-list)
	    (copy-list (map 'list #'(lambda (x) (first x)) (nth 1 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 1 cube) i) 0) (elt set-list i)))))
       ((eq side 'bottom)
	(if (null set-list)
	    (copy-list (first (last (nth 5 cube))))
	    (setf (first (last (nth 5 cube))) set-list)))
       ((eq side 'right)
	(if (null set-list)
	    (copy-list (map 'list #'(lambda (x) (first (last x))) (nth 3 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 3 cube) i) 2) (elt set-list i)))))
       (t nil)))     
    ((eq face 'right) ; order: top back bottom front
     (cond
       ((eq side 'top)
	(if (null set-list)
	    (copy-list (map 'list #'(lambda (x) (first (last x))) (nth 4 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 4 cube) i) 2) (elt set-list i)))))
       ((eq side 'back)
	(if (null set-list)
	    (copy-list (map 'list #'(lambda (x) (first x)) (nth 2 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 2 cube) i) 0) (elt set-list i)))))
       ((eq side 'bottom)
	(if (null set-list)
	    (copy-list (map 'list #'(lambda (x) (first (last x))) (nth 5 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 5 cube) i) 2) (elt set-list i)))))
       ((eq side 'front) 
	(if (null set-list)
	    (copy-list (map 'list #'(lambda (x) (first (last x))) (nth 0 cube)))
	    (dotimes (i 3)
	      (setf (elt (elt (nth 0 cube) i) 2) (elt set-list i)))))
       (t nil)))
    ((eq face 'top) ; order: back right front left
     (cond
       ((eq side 'back)
	(if (null set-list)
	    (copy-list (first (nth 2 cube)))
	    (setf (first (nth 2 cube)) set-list)))
       ((eq side 'right)
	(if (null set-list)
	    (copy-list (first (nth 3 cube)))
	    (setf (first (nth 3 cube)) set-list)))
       ((eq side 'front)
	(if (null set-list)
	    (copy-list (first (nth 0 cube)))
	    (setf (first (nth 0 cube)) set-list)))
       ((eq side 'left) 
	(if (null set-list)
	    (copy-list (first (nth 1 cube)))
	    (setf (first (nth 1 cube)) set-list)))
       (t nil)))
    ((eq face 'bottom) ; order: front right back left
     (cond
       ((eq side 'front)
	(if (null set-list)
	    (copy-list (first (last (nth 0 cube))))
	    (setf (first (last (nth 0 cube))) set-list)))
       ((eq side 'right)
	(if (null set-list)
	    (copy-list (first (last (nth 3 cube))))
	    (setf (first (last (nth 3 cube))) set-list)))
       ((eq side 'back)
	(if (null set-list)
	    (copy-list (first (last (nth 2 cube))))
	    (setf (first (last (nth 2 cube))) set-list)))
       ((eq side 'left)
	(if (null set-list)
	    (copy-list (first (last (nth 1 cube))))
	    (setf (first (last (nth 1 cube))) set-list)))
       (t nil)))
    (t nil)))
	
	

