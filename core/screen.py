import ctypes
import win32api
import win32con

def get_screen_size():
    return (
        win32api.GetSystemMetrics(0),
        win32api.GetSystemMetrics(1)
    )

def set_screen_size(width, height):
    devmode = win32api.EnumDisplaySettings(None, 0)
    devmode.PelsWidth = width
    devmode.PelsHeight = height
    devmode.Fields = win32con.DM_PELSWIDTH | win32con.DM_PELSHEIGHT
    win32api.ChangeDisplaySettings(devmode, 0) 