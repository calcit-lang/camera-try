
{} (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:version |0.0.1)
    :modules $ [] |respo.calcit/ |lilac/ |memof/ |respo-ui.calcit/ |reel.calcit/
  :entries $ {}
  :files $ {}
    |app.comp.container $ %{} :FileEntry
      :defs $ {}
        |comp-container $ %{} :CodeEntry (:doc |)
          :code $ quote
            defcomp comp-container (reel)
              let
                  store $ :store reel
                  states $ :states store
                  cursor $ or (:cursor states) ([])
                  state $ or (:data states)
                    {} $ :content "\""
                [] (effect-load-video)
                  div
                    {}
                      :class-name $ str-spaced css/global css/row css/fullscreen css/flex
                      :style $ {} (; :flex 1)
                        :background-color $ hsl 170 20 18
                    create-element :video $ {} (:class-name style-video) (:plays-inline true) (:autoplay true)
                    when dev? $ comp-reel (>> states :reel) reel ({})
        |connect-video! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn connect-video! (el) (hint-fn async) (; js/console.log "js/stream.getVideoTracks()[0].getSettings().aspectRatio")
              let
                  constraints $ js-object (:audio false)
                    :video $ {}
                  stream $ js-await (js/navigator.mediaDevices.getUserMedia constraints)
                  video-el $ .!querySelector el "\"video"
                set! (.-srcObject video-el) stream
                ; set! (.-srcObject js/window) stream
                js/console.log "js/stream.getVideoTracks()[0].getSettings().aspectRatio"
                js/console.log "\"Connected Video."
        |effect-load-video $ %{} :CodeEntry (:doc |)
          :code $ quote
            defeffect effect-load-video () (action el at?)
              if (= action :mount)
                try (connect-video! el)
                  fn (e) (js/console.error e)
        |style-video $ %{} :CodeEntry (:doc |)
          :code $ quote
            defstyle style-video $ {}
              "\"&" $ {} (:transform "\"scaleX(-1)") (:margin :auto)
                :border $ str-spaced "\"6px solid" (hsl 0 0 32)
                :border-radius "\"8px"
                :box-shadow $ str-spaced "\"0 0 1px" (hsl 0 0 0)
                :transition-duration "\"240ms"
                :min-height "\"72vh"
                :translate "\"0px 1px"
              "\"&:hover" $ {}
                :box-shadow $ str-spaced "\"0 2px 6px" (hsl 0 0 0 0.2)
                :translate "\"0px 0px"
      :ns $ %{} :CodeEntry (:doc |)
        :code $ quote
          ns app.comp.container $ :require (respo-ui.core :as ui)
            respo.core :refer $ defcomp defeffect <> >> div button textarea span input create-element
            respo.comp.space :refer $ =<
            reel.comp.reel :refer $ comp-reel
            app.config :refer $ dev?
            respo.css :refer $ defstyle
            respo-ui.css :as css
            respo.util.format :refer $ hsl
    |app.config $ %{} :FileEntry
      :defs $ {}
        |dev? $ %{} :CodeEntry (:doc |)
          :code $ quote
            def dev? $ = "\"dev" (get-env "\"mode" "\"release")
        |site $ %{} :CodeEntry (:doc |)
          :code $ quote
            def site $ {} (:storage-key "\"workflow")
      :ns $ %{} :CodeEntry (:doc |)
        :code $ quote (ns app.config)
    |app.main $ %{} :FileEntry
      :defs $ {}
        |*reel $ %{} :CodeEntry (:doc |)
          :code $ quote
            defatom *reel $ -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
        |dispatch! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn dispatch! (op)
              when
                and config/dev? $ not= op :states
                js/console.log "\"Dispatch:" op
              reset! *reel $ reel-updater updater @*reel op
        |main! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn main! ()
              println "\"Running mode:" $ if config/dev? "\"dev" "\"release"
              if config/dev? $ load-console-formatter!
              render-app!
              add-watch *reel :changes $ fn (reel prev) (render-app!)
              listen-devtools! |k dispatch!
              js/window.addEventListener |beforeunload $ fn (event) (persist-storage!)
              flipped js/setInterval 60000 persist-storage!
              let
                  raw $ js/localStorage.getItem (:storage-key config/site)
                when (some? raw)
                  dispatch! $ :: :hydrate-storage (parse-cirru-edn raw)
              println "|App started."
        |mount-target $ %{} :CodeEntry (:doc |)
          :code $ quote
            def mount-target $ .!querySelector js/document |.app
        |persist-storage! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn persist-storage! () (js/console.log "\"persist")
              js/localStorage.setItem (:storage-key config/site)
                format-cirru-edn $ :store @*reel
        |reload! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn reload! () $ if (nil? build-errors)
              do (remove-watch *reel :changes) (clear-cache!)
                add-watch *reel :changes $ fn (reel prev) (render-app!)
                reset! *reel $ refresh-reel @*reel schema/store updater
                hud! "\"ok~" "\"Ok"
              hud! "\"error" build-errors
        |render-app! $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn render-app! () $ render! mount-target (comp-container @*reel) dispatch!
      :ns $ %{} :CodeEntry (:doc |)
        :code $ quote
          ns app.main $ :require
            respo.core :refer $ render! clear-cache!
            app.comp.container :refer $ comp-container
            app.updater :refer $ updater
            app.schema :as schema
            reel.util :refer $ listen-devtools!
            reel.core :refer $ reel-updater refresh-reel
            reel.schema :as reel-schema
            app.config :as config
            "\"./calcit.build-errors" :default build-errors
            "\"bottom-tip" :default hud!
    |app.schema $ %{} :FileEntry
      :defs $ {}
        |store $ %{} :CodeEntry (:doc |)
          :code $ quote
            def store $ {}
              :states $ {}
                :cursor $ []
      :ns $ %{} :CodeEntry (:doc |)
        :code $ quote (ns app.schema)
    |app.updater $ %{} :FileEntry
      :defs $ {}
        |updater $ %{} :CodeEntry (:doc |)
          :code $ quote
            defn updater (store op op-id op-time)
              tag-match op
                  :states cursor s
                  update-states store cursor s
                (:hydrate-storage data) data
                _ $ do (println "\"unknown op:" op) store
      :ns $ %{} :CodeEntry (:doc |)
        :code $ quote
          ns app.updater $ :require
            respo.cursor :refer $ update-states
