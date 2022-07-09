(defproject superleague-clojure "0.1.0-SNAPSHOT"
  :description "SuperLeague in Clojure"
  :url "https://code.frickelbude.ch/m426/superleague-clojure"
  :dependencies [[org.clojure/clojure "1.10.3"]
                 [org.clojure/data.json "2.4.0"]]
  :main ^:skip-aot superleague-clojure.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all
                       :jvm-opts ["-Dclojure.compiler.direct-linking=true"]}})
