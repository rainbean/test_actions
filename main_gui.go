// +build gui

package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"

	"github.com/getlantern/systray"
	"github.com/kardianos/osext"
	"github.com/skratchdot/open-golang/open"
)

var assets string

func init() {
	// decide assets path
	execDir, _ := osext.ExecutableFolder()
	assets = filepath.Join(execDir, "assets")
	if _, err := os.Stat(assets); os.IsNotExist(err) {
		assets, _ = filepath.Abs("assets")
	}

	// serve as system tray, blocking
	systray.Run(onReady, onExit)
}

func onReady() {
	var p string
	if runtime.GOOS == "windows" {
		p = filepath.Join(assets, "Icon.ico")
	} else {
		p = filepath.Join(assets, "Icon.png")
	}
	// create system tray menu
	icon, err := ioutil.ReadFile(p)
	if err != nil {
		log.Fatal("invalid icon")
	}
	systray.SetIcon(icon)
	systray.SetTooltip("hello")
	n := 0
	mLink := systray.AddMenuItem("Google", "Open URL")
	mClick := systray.AddMenuItem("Click Me", "Add click count")
	mQuit := systray.AddMenuItem("Quit", "Quit app")
	// run dispatcher
	// read command line arguments and decide to run once or background jobs
	// event loop
	for {
		select {
		case <-mClick.ClickedCh:
			n++
			mClick.SetTitle(fmt.Sprintf("Clicked %d", n))
		case <-mLink.ClickedCh:
			open.Run("https://www.google.com")
		case <-mQuit.ClickedCh:
			systray.Quit()
			return
		}
	}
}

func onExit() {
	// clean up here
}
