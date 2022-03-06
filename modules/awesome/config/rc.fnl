(pcall require :luarocks.loader)
(require :awful.autofocus)

(let [naughty (require :naughty)]
  (naughty.connect_signal 
    "request::display_error"
    (fn [message startup?]
      (let [ending (if startup? " during start-up" "")
            title  (.. "Oops, an error occurred" ending "!")]
        (naughty.notification
          {:urgency :critical
           :title   title
           :message message})))))

(let [beautiful (require :beautiful)
      gears     (require :gears)]
  (beautiful.init
    (.. (gears.filesystem.get_configuration_dir) "misc/theme.lua")))

  ; Load wallpaper on all screens
  ;(for [idx 1 (screen.count) 1]))
  ;  (gears.wallpaper.maximised beautiful.wallpapers idx true)))

;; Misc
(require :misc)

;; UI Components
(require :components.bar)
(require :components.titlebar)
(require :components.context-menu)
(require :components.notifications)

;; Binds
(require :misc.binds.mouse)
(require :misc.binds.keyboard)

