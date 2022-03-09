import XMonad
import Data.Monoid
import System.Exit

import XMonad.Util.Run
import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig(additionalKeysP)
import XMonad.Util.NamedScratchpad

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog

import XMonad.Layout.NoBorders
import XMonad.Layout.Grid (Grid(..))
import XMonad.Layout.MultiColumns
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances

import XMonad.Actions.CycleWS

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "kitty"
myBrowser       = "brave"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = True

myBorderWidth   = 3

myModMask       = mod4Mask

myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

myNormalBorderColor  = "#000000"
myFocusedBorderColor = "#6b0080"

myKeys :: [(String, X())]
myKeys = [
    -- Spawn app
     ("M-<Return>", spawn (myTerminal))
    ,("M-d", spawn "dmenu_run")
    ,("M-S-f", spawn (myBrowser))
    ,("M-S-t", spawn "pcmanfm")
    ,("M-S-m", spawn $ myTerminal ++ " -e alsamixer")

    --Kill
    ,("M-S-c", kill)

    -- Restart
    ,("M-C-r", spawn "xmonad --recompile && xmonad --restart")
    ,("M-C-q", io (exitWith ExitSuccess))

    -- Lock
    ,("M-C-v", spawn "i3lock -i ~/.config/i3/img/hd_wallpaper_16065.png -te")

    -- Navigate
    ,("M-j", windows W.focusDown)
    ,("M-k", windows W.focusUp)
    ,("M-h", windows W.focusMaster)
    ,("M-S-j", windows W.swapDown)
    ,("M-S-k", windows W.swapUp)
    ,("M-S-h", windows W.swapMaster)

    -- Monitor
    ,("M-o", nextScreen)
    ,("M-S-o", shiftNextScreen)

    -- Layout
    ,("M-<Tab>", sendMessage NextLayout)
    --,("M-S-<Tab>", sendMessage PrevLayout)
    ,("M-f", sendMessage $ Toggle NBFULL)

    -- Float
    ,("M-t", withFocused (windows . W.sink))

    --Worspace
    ,("M-&", windows $ W.greedyView "1")
    ,("M-é", windows $ W.greedyView "2")
    ,("M-\"", windows $ W.greedyView "3")
    ,("M-'", windows $ W.greedyView "4")
    ,("M-(", windows $ W.greedyView "5")
    ,("M-§", windows $ W.greedyView "6")
    ,("M-è", windows $ W.greedyView "7")
    ,("M-!", windows $ W.greedyView "8")
    ,("M-ç", windows $ W.greedyView "9")

    ,("M-S-&", windows $ W.shift "1")
    ,("M-S-é", windows $ W.shift "2")
    ,("M-S-\"", windows $ W.shift "3")
    ,("M-S-'", windows $ W.shift "4")
    ,("M-S-(", windows $ W.shift "5")
    ,("M-S-§", windows $ W.shift "6")
    ,("M-S-è", windows $ W.shift "7")
    ,("M-S-!", windows $ W.shift "8")
    ,("M-S-ç", windows $ W.shift "9")
    ]

numPadKeys = [ xK_KP_End, xK_KP_Down, xK_KP_Page_Down , xK_KP_Left, xK_KP_Begin, xK_KP_Right , xK_KP_Home, xK_KP_Up, xK_KP_Page_Up , xK_KP_Insert] 

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
    ]

myLayout = mkToggle( NBFULL ?? EOT) . avoidStruts  $ (multi ||| Grid ||| Mirror tail ||| tail ||| noBorders Full)
  where
    multi   = multiCol [1] 1 0.01 (-0.5)
    tail = Tall 1 (10/100) (50/100)

myManageHook = mempty

myEventHook = mempty

myStartupHook = do
    spawnOnce "xmodmap ~/.config/i3/xmodmaprc &"
    -- spawnOnce "xrandr --output HDMI1 --auto --right-of eDP1 &"
    spawnOnce "xrandr --output DP1-9 --auto --right-of eDP1"
    spawnOnce "xrandr --output HDMI1 --auto --right-of DP1-9"
    spawnOnce "exec ~/.config/i3/fehbg &"
    spawnOnce "nm-applet &"

main = do 
    xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc0"
    xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc0"
    xmonad $ docks def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

        mouseBindings      = myMouseBindings,
        keys               = mempty,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook <+> manageDocks,
        handleEventHook    = myEventHook,
        logHook            = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP { ppOutput = \x -> hPutStrLn xmproc0 x >> hPutStrLn xmproc1 x },
        startupHook        = myStartupHook
    } `additionalKeysP` myKeys
