import time
import pygetwindow as gw

from core.execute import career_lobby
from core.screen import get_screen_size, set_screen_size

def focus_umamusume():
  windows = gw.getWindowsWithTitle("Umamusume")
  if not windows:
    raise Exception("Umamusume not found.")
  win = windows[0]
  if win.isMinimized:
    win.restore()
  win.activate()
  win.maximize()
  time.sleep(0.5)

def wait_for_game_start():
  while True:
    time.sleep(1)
    if gw.getActiveWindow().title == "Umamusume":
      break

def main():
  print("Uma Auto!")
  original_screen_size = get_screen_size()
  width, height = original_screen_size

  if width < 1920 or height < 1080:
    print("Error: Screen resolution must be at least 1920x1080.")
    return
  
  resolution_changed = False
  if width != 1920 or height != 1080:
    print("Change resolution to 1920x1080.")
    set_screen_size(1920, 1080)
    resolution_changed = True
    print("Please press the game to continue.")
  try:
    wait_for_game_start()

    focus_umamusume()

    career_lobby()
  finally:
    if resolution_changed:
      print("Restore screen resolution.")
      set_screen_size(original_screen_size[0], original_screen_size[1])


if __name__ == "__main__":
  main()
