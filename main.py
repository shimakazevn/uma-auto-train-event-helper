import time
import pygetwindow as gw
import win32gui
import win32con
import tkinter as tk
import threading
import queue
from utils.gui import BotGUI

from core.execute import career_lobby
from core.screen import get_screen_size, set_screen_size

class GameWindow:
    def __init__(self):
        self.uma_hwnd = None
        self.original_style = None
        self.original_ex_style = None
        
    def make_borderless(self):
        windows = gw.getWindowsWithTitle("Umamusume")
        if not windows:
            raise Exception("Umamusume not found.")
        uma_window = windows[0]
        if uma_window.isMinimized:
            uma_window.restore()
        
        if not uma_window.isActive:
            uma_window.activate()
        
        # Get the Umamusume window handle
        self.uma_hwnd = win32gui.FindWindow(None, "Umamusume")
        
        # Save original styles
        self.original_style = win32gui.GetWindowLong(self.uma_hwnd, win32con.GWL_STYLE)
        self.original_ex_style = win32gui.GetWindowLong(self.uma_hwnd, win32con.GWL_EXSTYLE)
        
        # Remove border and frame
        new_style = self.original_style & ~(win32con.WS_CAPTION | win32con.WS_THICKFRAME | 
                                          win32con.WS_SYSMENU | win32con.WS_MINIMIZEBOX | 
                                          win32con.WS_MAXIMIZEBOX)
        win32gui.SetWindowLong(self.uma_hwnd, win32con.GWL_STYLE, new_style)
        
        # Remove extended window styles
        new_ex_style = self.original_ex_style & ~(win32con.WS_EX_WINDOWEDGE | 
                                                 win32con.WS_EX_CLIENTEDGE | 
                                                 win32con.WS_EX_DLGMODALFRAME)
        win32gui.SetWindowLong(self.uma_hwnd, win32con.GWL_EXSTYLE, new_ex_style)
        
        # Position window at top-left corner
        x = 0  # Left edge of screen
        y = 0  # Top edge of screen
        
        # Set window position and size
        win32gui.SetWindowPos(self.uma_hwnd, None, x, y, 1920, 1080, 
                             win32con.SWP_FRAMECHANGED)
        
        time.sleep(0.5)
        
    def restore_window(self):
        if self.uma_hwnd and self.original_style and self.original_ex_style:
            # Restore original styles
            win32gui.SetWindowLong(self.uma_hwnd, win32con.GWL_STYLE, self.original_style)
            win32gui.SetWindowLong(self.uma_hwnd, win32con.GWL_EXSTYLE, self.original_ex_style)
            # Force window to redraw
            win32gui.SetWindowPos(self.uma_hwnd, None, 0, 0, 0, 0,
                                win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | 
                                win32con.SWP_NOZORDER | win32con.SWP_FRAMECHANGED)

def focus_umamusume():
    game_window = GameWindow()
    game_window.make_borderless()
    return game_window

def wait_for_game_start():
  while True:
    time.sleep(1)
    active_window = gw.getActiveWindow()
    if active_window and active_window.title == "Umamusume":
      break

class UmaMusumeBot:
    def __init__(self):
        self.game_window = None
        self.is_running = False
        self.bot_thread = None
        self.gui = None
        self.log_queue = queue.Queue()
        self.stop_event = threading.Event()

    def start_bot(self):
        if not self.is_running:
            self.is_running = True
            self.stop_event.clear()
            self.bot_thread = threading.Thread(target=self._bot_loop)
            self.bot_thread.daemon = True
            self.bot_thread.start()
            self.log("Bot thread started")

    def stop_bot(self):
        if not self.is_running:
            return
            
        self.log("Stopping bot...")
        # Set flags first
        self.is_running = False
        self.stop_event.set()
        
        # Give the thread a chance to stop gracefully
        if self.bot_thread and self.bot_thread.is_alive():
            try:
                for _ in range(5):  # Try multiple times with shorter timeouts
                    self.bot_thread.join(timeout=1.0)
                    if not self.bot_thread.is_alive():
                        break
                if self.bot_thread.is_alive():
                    self.log("[WARNING] Bot thread did not stop gracefully")
            except Exception as e:
                self.log(f"[ERROR] Error stopping bot thread: {str(e)}")
        
        # Call cleanup once
        self.cleanup()

    def _bot_loop(self):
        try:
            if not self.game_window:
                wait_for_game_start()
                self.game_window = focus_umamusume()
                self.log("Game window initialized")
            
            while not self.stop_event.is_set():  # Only check stop_event
                try:
                    # Check stop event before each iteration
                    if self.stop_event.is_set():
                        self.log("Stop event detected, exiting bot loop")
                        break
                    
                    # Run one iteration of the bot loop
                    career_lobby()
                    
                    # Check stop event after each action
                    for _ in range(10):
                        if self.stop_event.is_set():
                            self.log("Stop event detected after action")
                            return
                        time.sleep(0.1)
                        
                except Exception as e:
                    self.log(f"Error in bot loop: {str(e)}")
                    self.stop_bot()
                    break
                
        except Exception as e:
            self.log(f"Critical error: {str(e)}")
            self.stop_bot()
        finally:
            self.log("Bot loop ended")

    def log(self, message):
        if self.gui and hasattr(self.gui, 'log_area') and self.gui.log_area.winfo_exists():
            try:
                self.gui.log(message)
            except tk.TclError:
                # GUI has been destroyed, fall back to print
                print(message)
        else:
            print(message)

    def cleanup(self):
        """Clean up resources and restore window state"""
        # Set stop flags if not already set
        if self.is_running:
            self.is_running = False
            self.stop_event.set()
        
        # Give thread one last chance to stop
        if self.bot_thread and self.bot_thread.is_alive():
            try:
                self.bot_thread.join(timeout=1.0)
            except Exception as e:
                self.log(f"[WARNING] Error during final thread cleanup: {str(e)}")
        
        # Restore game window state
        if self.game_window:
            try:
                self.game_window.restore_window()
                self.game_window = None  # Clear reference
            except Exception as e:
                self.log(f"[WARNING] Error restoring game window: {str(e)}")
        
        # Use print instead of self.log to avoid GUI issues during cleanup
        print("Cleanup completed")

def main():
    print("Uma Auto!")
    root = tk.Tk()
    bot = UmaMusumeBot()
    
    # Create GUI
    gui = BotGUI(root, start_callback=bot.start_bot)
    bot.gui = gui
    
    try:
        root.protocol("WM_DELETE_WINDOW", lambda: [bot.cleanup(), root.destroy()])
        root.mainloop()
    except KeyboardInterrupt:
        bot.cleanup()
    finally:
        bot.cleanup()

if __name__ == "__main__":
    main()
