(ns superleague-clojure.core
  (:gen-class)
  (:require [clojure.string])
  (:require [clojure.data.json :as json]))

(defrecord TableRow [team rank wins defeats ties goals+ goals- goals= points])

(defn to-table-row [team our-goals their-goals]
  (let [diff (- our-goals their-goals)]
    (cond
      (= our-goals their-goals) (->TableRow team -1 0 0 1 our-goals their-goals diff 1)
      (> our-goals their-goals) (->TableRow team -1 1 0 0 our-goals their-goals diff 3)
      (< our-goals their-goals) (->TableRow team -1 0 1 0 our-goals their-goals diff 0))))

(defn to-table-rows [match]
  (let [ht (get match "homeTeam") at (get match "awayTeam")
        hg (get match "homeGoals") ag (get match "awayGoals")]
    [(to-table-row ht hg ag) (to-table-row at ag hg)]))

(defn merge-table-rows [a b]
  (into (->TableRow "" 0 0 0 0 0 0 0 0)
        (assoc (merge-with + (dissoc a :team) (dissoc b :team))
               :team (:team a))))

(defn by-points-goals-wins-team [a b]
  (cond ; desc points
    (> (:points a) (:points b)) -1
    (< (:points a) (:points b)) 1
    (= (:points a) (:points b))
    (cond ; desc goals diff.
      (> (:goals= a) (:goals= b)) -1
      (< (:goals= a) (:goals= b)) 1
      (= (:goals= a) (:goals= b))
      (cond ; desc wins
        (> (:wins a) (:wins b)) -1
        (< (:wins a) (:wins b)) 1
        (= (:wins a) (:wins b))
        (compare ; asc team
         (:team a) (:team b))))))

(defn combine-rank [row-rank]
  (assoc (first row-rank) :rank (second row-rank)))

(defn format-table [rows]
  (let [title-line (format "%25s %2s %2s %2s %2s %2s %2s %3s %2s"
                           "Team" "#" "w" "l" "d" "+" "-" "=" "P")]
    (clojure.string/join "\n"
                         (flatten [title-line
                                   (clojure.string/join (repeat (count title-line) "-"))
                                   (map
                                    (fn [r]
                                      (format "%25s %2d %2d %2d %2d %2d %2d %3d %2d"
                                              (:team r) (:rank r) (:wins r) (:defeats r) (:ties r)
                                              (:goals+ r) (:goals- r) (:goals= r) (:points r))) rows)]))))

(defn -main
  [& args]
  (let [matches (json/read-str (slurp (first args)))
        team-rows (group-by :team (flatten (map to-table-rows matches)))
        table (sort by-points-goals-wins-team
                    (map (fn [team-name]
                           (reduce merge-table-rows
                                   (get team-rows team-name)))
                         (keys team-rows)))]
    (println
     (format-table
      (sort-by :rank
               (map combine-rank
                    (partition 2 (interleave table (iterate inc 1)))))))))
