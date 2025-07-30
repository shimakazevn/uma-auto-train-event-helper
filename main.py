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

def main():
  print("Uma Auto!")
  original_screen_size = get_screen_size()
  
  try:
    set_screen_size(1920, 1080)
    focus_umamusume()
    
    career_lobby()
  finally:
    set_screen_size(original_screen_size[0], original_screen_size[1])


if __name__ == "__main__":
  main()
