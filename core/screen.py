import ctypes
import win32api

def get_screen_size():
    return (
        win32api.GetSystemMetrics(0),
        win32api.GetSystemMetrics(1)
    )

def set_screen_size(width, height):
    devmode = win32api.EnumDisplaySettings(None, 0)
    devmode.PelsWidth = width
    devmode.PelsHeight = height
    devmode.BitsPerPel = 32
    devmode.DisplayFixedOutput = 0
    win32api.ChangeDisplaySettings(devmode, 0) 