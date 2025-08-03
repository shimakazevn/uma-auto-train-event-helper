import time
import pygetwindow as gw
import win32gui
import win32con

from core.execute import career_lobby
from core.screen import get_screen_size, set_screen_size

def focus_umamusume():
    windows = gw.getWindowsWithTitle("Umamusume")
    if not windows:
        raise Exception("Umamusume not found.")
    uma_window = windows[0]
    if uma_window.isMinimized:
        uma_window.restore()
    
    if not uma_window.isActive:
        uma_window.activate()
    
    # Get the Umamusume window handle
    uma_hwnd = win32gui.FindWindow(None, "Umamusume")
    
    # Remove border and frame
    style = win32gui.GetWindowLong(uma_hwnd, win32con.GWL_STYLE)
    new_style = style & ~(win32con.WS_CAPTION | win32con.WS_THICKFRAME | win32con.WS_SYSMENU | win32con.WS_MINIMIZEBOX | win32con.WS_MAXIMIZEBOX)
    win32gui.SetWindowLong(uma_hwnd, win32con.GWL_STYLE, new_style)
    
    # Remove extended window styles
    ex_style = win32gui.GetWindowLong(uma_hwnd, win32con.GWL_EXSTYLE)
    new_ex_style = ex_style & ~(win32con.WS_EX_WINDOWEDGE | win32con.WS_EX_CLIENTEDGE | win32con.WS_EX_DLGMODALFRAME)
    win32gui.SetWindowLong(uma_hwnd, win32con.GWL_EXSTYLE, new_ex_style)
    
    # Position window at top-left corner
    x = 0  # Left edge of screen
    y = 0  # Top edge of screen
    
    # Set window position and size
    win32gui.SetWindowPos(uma_hwnd, None, x, y, 1920, 1080, 
                         win32con.SWP_FRAMECHANGED)
    
    time.sleep(0.5)

def wait_for_game_start():
  while True:
    time.sleep(1)
    active_window = gw.getActiveWindow()
    if active_window and active_window.title == "Umamusume":
      break

def main():
    print("Uma Auto!")
    try:
        wait_for_game_start()
        focus_umamusume()
        career_lobby()
    except Exception as e:
        print(f"Error: {e}")
        raise


if __name__ == "__main__":
  main()
