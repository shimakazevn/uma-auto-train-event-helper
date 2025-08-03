import json
import os
import sys
import time
import pyautogui
import tkinter as tk
from tkinter import ttk, messagebox
from pyautogui import ImageNotFoundException
import win32gui
import win32con
import pygetwindow as gw

# Add parent directory to Python path to allow imports from core and utils
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.screenshot import capture_region
from core.ocr import extract_event_name_text

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

class EventOverlay:
    def __init__(self):
        self.event_region = (243, 201, 365, 45)
        self.overlay_x = 958
        self.overlay_y = 760
        self.overlay_width = 798
        self.overlay_height = 320
        self.support_events = []
        self.uma_events = []
        self.ura_finale_events = []
        self.game_window = None
        self.load_databases()
        self.validate_and_fix_game_window()
        self.setup_overlay()
        self.last_event_name = None
        self.event_displayed = False
        self.event_detection_start = None

    def validate_and_fix_game_window(self):
        """Kiểm tra và tự động sửa cấu hình game window"""
        print("🔍 Kiểm tra và cấu hình cửa sổ game...")
        
        # Tìm cửa sổ game
        game_window = None
        possible_names = ["umamusume", "uma musume", "ウマ娘", "ウマ娘 プリティーダービー"]
        
        def enum_windows_callback(hwnd, windows):
            if win32gui.IsWindowVisible(hwnd):
                window_text = win32gui.GetWindowText(hwnd).lower()
                for name in possible_names:
                    if name in window_text:
                        windows.append((hwnd, window_text))
            return True
        
        windows = []
        win32gui.EnumWindows(enum_windows_callback, windows)
        
        if not windows:
            print("❌ Không tìm thấy cửa sổ game!")
            print("Vui lòng đảm bảo:")
            print("• Game đang chạy")
            print("• Game ở chế độ borderless")
            print("• Độ phân giải 1920x1080")
            print("• Cửa sổ game nằm ở góc trên trái màn hình")
            print()
            print("Hướng dẫn cài đặt game:")
            print("1. Mở game Uma Musume")
            print("2. Vào Settings > Display")
            print("3. Chọn Borderless mode")
            print("4. Đặt độ phân giải 1920x1080")
            print("5. Di chuyển game về góc trên trái màn hình")
            print()
            print("Bạn có muốn tiếp tục mà không kiểm tra không? (y/n): ", end="")
            
            try:
                response = input().lower().strip()
                if response in ['y', 'yes', 'có', 'co']:
                    print("⚠️ Bỏ qua kiểm tra game window")
                    return
                else:
                    print("🛑 Dừng chương trình")
                    sys.exit(1)
            except KeyboardInterrupt:
                print("\n🛑 Dừng chương trình")
                sys.exit(1)
        
        game_window = windows[0][0]  # Lấy cửa sổ đầu tiên tìm thấy
        print(f"✅ Tìm thấy cửa sổ game: {windows[0][1]}")
        
        # Kiểm tra vị trí và kích thước cửa sổ
        rect = win32gui.GetWindowRect(game_window)
        x, y, right, bottom = rect
        width = right - x
        height = bottom - y
        
        print(f"📍 Vị trí cửa sổ: ({x}, {y})")
        print(f"📏 Kích thước cửa sổ: {width}x{height}")
        
        # Kiểm tra xem có cần sửa không
        needs_fix = False
        errors = []
        
        if x != 0 or y != 0:
            errors.append(f"❌ Vị trí không đúng: ({x}, {y}) - Yêu cầu: (0, 0)")
            needs_fix = True
        
        if width != 1920 or height != 1080:
            errors.append(f"❌ Độ phân giải không đúng: {width}x{height} - Yêu cầu: 1920x1080")
            needs_fix = True
        
        # Kiểm tra xem có phải borderless không (không có thanh tiêu đề)
        style = win32gui.GetWindowLong(game_window, win32con.GWL_STYLE)
        if style & win32con.WS_CAPTION:
            errors.append("❌ Game không ở chế độ borderless")
            needs_fix = True
        
        if needs_fix:
            print("⚠️ Cấu hình game không đúng:")
            for error in errors:
                print(f"   {error}")
            print()
            print("🛠️ Đang tự động sửa cấu hình game...")
            
            try:
                # Sử dụng GameWindow class để tự động sửa
                self.game_window = GameWindow()
                self.game_window.make_borderless()
                print("✅ Đã tự động sửa cấu hình game thành công!")
                print("   • Chuyển sang borderless mode")
                print("   • Đặt độ phân giải 1920x1080")
                print("   • Di chuyển về góc trên trái")
                print()
            except Exception as e:
                print(f"❌ Lỗi khi sửa cấu hình game: {str(e)}")
                print("Vui lòng thử sửa thủ công:")
                print("1. Vào Settings > Display trong game")
                print("2. Chọn Borderless mode")
                print("3. Đặt độ phân giải 1920x1080")
                print("4. Di chuyển game về góc trên trái màn hình")
                print()
                print("Bạn có muốn tiếp tục mà không sửa không? (y/n): ", end="")
                
                try:
                    response = input().lower().strip()
                    if response in ['y', 'yes', 'có', 'co']:
                        print("⚠️ Bỏ qua sửa cấu hình game")
                        print("⚠️ Lưu ý: Event Overlay có thể không hoạt động chính xác!")
                        return
                    else:
                        print("🛑 Dừng chương trình")
                        sys.exit(1)
                except KeyboardInterrupt:
                    print("\n🛑 Dừng chương trình")
                    sys.exit(1)
        else:
            print("✅ Game đang chạy đúng cấu hình:")
            print("   • Borderless mode")
            print("   • Độ phân giải 1920x1080")
            print("   • Vị trí góc trên trái")
            print()

    def load_databases(self):
        print("Loading event databases...")
        if os.path.exists("assets/events/support_card.json"):
            with open("assets/events/support_card.json", "r", encoding="utf-8-sig") as f:
                self.support_events = json.load(f)
            print(f"   ✓ Loaded {len(self.support_events)} support card events")
        if os.path.exists("assets/events/uma_data.json"):
            with open("assets/events/uma_data.json", "r", encoding="utf-8-sig") as f:
                uma_data = json.load(f)
                for character in uma_data:
                    if "UmaEvents" in character:
                        self.uma_events.extend(character["UmaEvents"])
            print(f"   ✓ Loaded {len(self.uma_events)} uma events")
        if os.path.exists("assets/events/ura_finale.json"):
            with open("assets/events/ura_finale.json", "r", encoding="utf-8-sig") as f:
                self.ura_finale_events = json.load(f)
            print(f"   ✓ Loaded {len(self.ura_finale_events)} ura finale events")
        print("   ✓ Databases loaded successfully")

    def setup_overlay(self):
        self.root = tk.Tk()
        self.root.title("Event Overlay")
        self.root.geometry(f"{self.overlay_width}x{self.overlay_height}+{self.overlay_x}+{self.overlay_y}")
        self.root.overrideredirect(True)
        self.root.attributes('-topmost', True)
        
        # Cải thiện style
        style = ttk.Style()
        style.theme_use('clam')
        
        # Tạo main frame với background tối hoàn toàn
        self.main_frame = ttk.Frame(self.root, padding="13")
        self.main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Tạo frame cho header với background tối
        header_frame = ttk.Frame(self.main_frame)
        header_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Title với font lớn hơn và màu đẹp hơn
        self.title_label = ttk.Label(
            header_frame, 
            text="🎮 Event Information", 
            font=('Segoe UI', 10, 'bold'), 
            foreground='#4A90E2'
        )
        self.title_label.pack(side=tk.LEFT)
        
        # Nút close (X) với background tối
        close_button = tk.Button(
            header_frame,
            text="✕",
            font=('Segoe UI', 10, 'bold'),
            fg='#FFFFFF',
            bg='#E74C3C',
            activebackground='#C0392B',
            activeforeground='#FFFFFF',
            relief=tk.FLAT,
            borderwidth=0,
            width=3,
            height=1,
            cursor='hand2',
            command=self.on_closing
        )
        close_button.pack(side=tk.RIGHT, padx=(10, 0))
        
        # Event name label với font lớn hơn
        self.event_name_label = ttk.Label(
            self.main_frame, 
            text="Waiting for events...", 
            font=('Segoe UI', 11), 
            foreground='#E74C3C'
            
        )
        self.event_name_label.pack(pady=(0, 15))
        
        # Text area với font lớn hơn và background tối hoàn toàn
        self.options_text = tk.Text(
            self.main_frame, 
            height=10, 
            width=70, 
            font=('Consolas', 11),  # Tăng font size từ 10 lên 12
            wrap=tk.WORD, 
            bg='#000000',  # Background đen hoàn toàn
            fg='#FFFFFF', 
            insertbackground='white', 
            selectbackground='#4A90E2',
            relief=tk.FLAT,
            borderwidth=0,  # Giảm borderwidth từ 2 xuống 0
            padx=5,  # Thêm padding nhỏ cho text
            pady=5   # Thêm padding nhỏ cho text
        )
        self.options_text.pack(fill=tk.BOTH, expand=True, pady=(0, 5))
        
        # Status label với font lớn hơn
        self.status_label = ttk.Label(
            self.main_frame, 
            text="🔄 Monitoring for events...", 
            font=('Segoe UI', 10),  # Tăng font size từ 10 lên 12
            foreground='#95A5A6'
        )
        self.status_label.pack(side=tk.LEFT)
        

        
        # Cấu hình style cho tất cả frame để có background tối
        style.configure('TFrame', background='#1E1E1E')
        style.configure('TLabel', background='#1E1E1E')
        
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        self.monitor_events()

    def generate_event_variations(self, event_name):
        event_variations = [event_name]
        import re
        if 'l' in event_name:
            variation = re.sub(r'l\b', '!', event_name)
            if variation != event_name and variation not in event_variations:
                event_variations.append(variation)
            variation2 = re.sub(r'l([!?.,])', r'!\1', event_name)
            if variation2 != event_name and variation2 not in event_variations:
                event_variations.append(variation2)
        if '!' in event_name:
            variation = event_name.replace('!', 'l')
            if variation not in event_variations:
                event_variations.append(variation)
        if '%' in event_name:
            variation = event_name.replace('%', '☆')
            if variation not in event_variations:
                event_variations.append(variation)
        if '☆' in event_name:
            variation = event_name.replace('☆', '%')
            if variation not in event_variations:
                event_variations.append(variation)
        cleaned_variations = []
        for variation in event_variations:
            cleaned = re.sub(r'[!l]{2,}', '!', variation)
            if cleaned not in event_variations and cleaned != variation:
                cleaned_variations.append(cleaned)
            # Add variation without trailing exclamation marks
            no_exclamation = re.sub(r'!+$', '', variation).strip()
            if no_exclamation not in event_variations and no_exclamation != variation and no_exclamation:
                cleaned_variations.append(no_exclamation)
            # Add variation without trailing single letters (OCR artifacts)
            no_trailing_letter = re.sub(r'\s+[A-Za-z]\s*$', '', variation).strip()
            if no_trailing_letter not in event_variations and no_trailing_letter != variation and no_trailing_letter:
                cleaned_variations.append(no_trailing_letter)
            no_trailing_letter2 = re.sub(r'[A-Za-z]\s*$', '', variation).strip()
            if no_trailing_letter2 not in event_variations and no_trailing_letter2 != variation and no_trailing_letter2:
                cleaned_variations.append(no_trailing_letter2)
        event_variations.extend(cleaned_variations)
        word_order_variations = []
        for variation in event_variations:
            words = variation.split()
            if len(words) >= 3:
                if len(words) == 3:
                    import itertools
                    for perm in itertools.permutations(words):
                        perm_text = ' '.join(perm)
                        if perm_text not in event_variations and perm_text != variation:
                            word_order_variations.append(perm_text)
                elif len(words) == 4:
                    first_half = ' '.join(words[:2])
                    second_half = ' '.join(words[2:])
                    swapped = f"{second_half} {first_half}"
                    if swapped not in event_variations and swapped != variation:
                        word_order_variations.append(swapped)
        event_variations.extend(word_order_variations)
        return event_variations

    def search_events(self, event_variations):
        found_events = {}
        for event in self.support_events:
            db_event_name = event.get("EventName", "").lower()
            clean_db_name = db_event_name.replace("(❯)", "").replace("(❯❯)", "").replace("(❯❯❯)", "").strip()
            for variation in event_variations:
                clean_search_name = variation.lower().strip()
                # Clean search name the same way as database names
                clean_search_name = clean_search_name.replace("(❯)", "").replace("(❯❯)", "").replace("(❯❯❯)", "").strip()
                if clean_db_name == clean_search_name:
                    event_name_key = event['EventName']
                    if event_name_key not in found_events:
                        found_events[event_name_key] = {"source": "Support Card", "options": {}}
                    event_options = event.get("EventOptions", {})
                    for option_name, option_reward in event_options.items():
                        if option_name and any(keyword in option_name.lower() for keyword in ["top option", "bottom option", "middle option", "option1", "option2", "option3"]):
                            found_events[event_name_key]["options"][option_name] = option_reward
                    break
                elif self.fuzzy_match(clean_search_name, clean_db_name) or self.smart_substring_match(clean_search_name, clean_db_name):
                    event_name_key = event['EventName']
                    if event_name_key not in found_events:
                        found_events[event_name_key] = {"source": "Support Card", "options": {}}
                    event_options = event.get("EventOptions", {})
                    for option_name, option_reward in event_options.items():
                        if option_name and any(keyword in option_name.lower() for keyword in ["top option", "bottom option", "middle option", "option1", "option2", "option3"]):
                            found_events[event_name_key]["options"][option_name] = option_reward
                    break
        for event in self.uma_events:
            db_event_name = event.get("EventName", "").lower()
            clean_db_name = db_event_name.replace("(❯)", "").replace("(❯❯)", "").replace("(❯❯❯)", "").strip()
            for variation in event_variations:
                clean_search_name = variation.lower().strip()
                # Clean search name the same way as database names
                clean_search_name = clean_search_name.replace("(❯)", "").replace("(❯❯)", "").replace("(❯❯❯)", "").strip()
                if clean_db_name == clean_search_name:
                    event_name_key = event['EventName']
                    if event_name_key not in found_events:
                        found_events[event_name_key] = {"source": "Uma Data", "options": {}}
                    elif found_events[event_name_key]["source"] == "Support Card":
                        found_events[event_name_key]["source"] = "Both"
                    event_options = event.get("EventOptions", {})
                    for option_name, option_reward in event_options.items():
                        if option_name and any(keyword in option_name.lower() for keyword in ["top option", "bottom option", "middle option", "option1", "option2", "option3"]):
                            found_events[event_name_key]["options"][option_name] = option_reward
                    break
                elif self.fuzzy_match(clean_search_name, clean_db_name) or self.smart_substring_match(clean_search_name, clean_db_name):
                    event_name_key = event['EventName']
                    if event_name_key not in found_events:
                        found_events[event_name_key] = {"source": "Uma Data", "options": {}}
                    elif found_events[event_name_key]["source"] == "Support Card":
                        found_events[event_name_key]["source"] = "Both"
                    event_options = event.get("EventOptions", {})
                    for option_name, option_reward in event_options.items():
                        if option_name and any(keyword in option_name.lower() for keyword in ["top option", "bottom option", "middle option", "option1", "option2", "option3"]):
                            found_events[event_name_key]["options"][option_name] = option_reward
                    break
        for event in self.ura_finale_events:
            db_event_name = event.get("EventName", "").lower()
            clean_db_name = db_event_name.replace("(❯)", "").replace("(❯❯)", "").replace("(❯❯❯)", "").strip()
            for variation in event_variations:
                clean_search_name = variation.lower().strip()
                # Clean search name the same way as database names
                clean_search_name = clean_search_name.replace("(❯)", "").replace("(❯❯)", "").replace("(❯❯❯)", "").strip()
                if clean_db_name == clean_search_name:
                    event_name_key = event['EventName']
                    if event_name_key not in found_events:
                        found_events[event_name_key] = {"source": "Ura Finale", "options": {}}
                    elif found_events[event_name_key]["source"] in ["Support Card", "Uma Data"]:
                        found_events[event_name_key]["source"] = "Multiple Sources"
                    event_options = event.get("EventOptions", {})
                    for option_name, option_reward in event_options.items():
                        if option_name and any(keyword in option_name.lower() for keyword in ["top option", "bottom option", "middle option", "option1", "option2", "option3"]):
                            found_events[event_name_key]["options"][option_name] = option_reward
                    break
                elif self.fuzzy_match(clean_search_name, clean_db_name) or self.smart_substring_match(clean_search_name, clean_db_name):
                    event_name_key = event['EventName']
                    if event_name_key not in found_events:
                        found_events[event_name_key] = {"source": "Ura Finale", "options": {}}
                    elif found_events[event_name_key]["source"] in ["Support Card", "Uma Data"]:
                        found_events[event_name_key]["source"] = "Multiple Sources"
                    event_options = event.get("EventOptions", {})
                    for option_name, option_reward in event_options.items():
                        if option_name and any(keyword in option_name.lower() for keyword in ["top option", "bottom option", "middle option", "option1", "option2", "option3"]):
                            found_events[event_name_key]["options"][option_name] = option_reward
                    break
        return found_events

    def fuzzy_match(self, search_name, db_name):
        common_words = ['the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by']
        search_words = [word for word in search_name.split() if word not in common_words]
        db_words = [word for word in db_name.split() if word not in common_words]
        if len(search_words) >= 2 and len(db_words) >= 2:
            matches = sum(1 for word in search_words if word in db_words)
            match_ratio = matches / max(len(search_words), len(db_words))
            return match_ratio >= 0.7  # Increased fuzzy match threshold for more precision
        elif len(search_words) == 1 and len(db_words) == 1:
            search_word = search_words[0]
            db_word = db_words[0]
            return search_word in db_word or db_word in search_word
        return False

    def smart_substring_match(self, search_name, db_name):
        """Smart substring matching that prevents short words from matching longer phrases"""
        # If search name is too short, don't match
        if len(search_name) < 8:
            return False
        
        # If search name is a single word and db_name has multiple words, be more careful
        search_words = search_name.split()
        db_words = db_name.split()
        
        if len(search_words) == 1 and len(db_words) > 1:
            # Single word search in multi-word database entry - require longer words
            search_word = search_words[0]
            # Remove punctuation for length check
            clean_word = ''.join(c for c in search_word if c.isalnum())
            if len(clean_word) < 8:
                return False
            # Only match if the search word appears as a complete word in the database entry
            return search_word in db_words
        else:
            # Multi-word search or single-word database entry
            # Be more strict: only allow substring matching if the search name is significantly shorter
            # This prevents "Shrine Visit" from matching "New Year's Shrine Visit"
            if len(search_name) >= len(db_name) * 0.8:  # Search name must be at least 80% of db_name length
                return False
            return search_name in db_name or db_name in search_name

    def update_overlay(self, event_name, found_events):
        if found_events:
            event_name_key = list(found_events.keys())[0]
            self.event_name_label.config(text=f"📋 {event_name_key}")
            self.options_text.delete(1.0, tk.END)
            
            for event_name_key, event_data in found_events.items():
                # Source với format đẹp hơn
                self.options_text.insert(tk.END, f"📍 Source: {event_data['source']}\n", "source")
                self.options_text.insert(tk.END, "\n")
                
                # Options header
                self.options_text.insert(tk.END, "🎯 Options:\n", "header")
                
                options = event_data["options"]
                if options:
                    for i, (option_name, option_reward) in enumerate(options.items(), 1):
                        # Format option với số thứ tự và màu sắc
                        reward_single_line = option_reward.replace("\r\n", ", ").replace("\n", ", ").replace("\r", ", ")
                        
                        # Thêm số thứ tự và format đẹp hơn
                        option_text = f"   {i}. {option_name}\n"
                        self.options_text.insert(tk.END, option_text, "option_name")
                        
                        # Reward với màu khác
                        reward_text = f"      → {reward_single_line}\n"
                        self.options_text.insert(tk.END, reward_text, "reward")
                    
                    # Tổng số options
                    option_count = len(options)
                    total_text = f"\n📊 Total options: {option_count}\n"
                    self.options_text.insert(tk.END, total_text, "total")
                else:
                    self.options_text.insert(tk.END, "   No valid options found\n", "no_options")
            
            # Cấu hình tags cho màu sắc
            self.options_text.tag_configure("source", foreground="#4A90E2", font=('Consolas', 11, 'bold'))
            self.options_text.tag_configure("header", foreground="#E74C3C", font=('Consolas', 11, 'bold'))
            self.options_text.tag_configure("option_name", foreground="#F39C12", font=('Consolas', 11))
            self.options_text.tag_configure("reward", foreground="#27AE60", font=('Consolas', 10))
            self.options_text.tag_configure("total", foreground="#9B59B6", font=('Consolas', 11, 'bold'))
            self.options_text.tag_configure("no_options", foreground="#E74C3C", font=('Consolas', 11))
            
            self.status_label.config(text="✅ Event found!", foreground='#28A745')
        else:
            self.event_name_label.config(text=f"❓ {event_name}")
            self.options_text.delete(1.0, tk.END)
            
            # Format error message đẹp hơn
            self.options_text.insert(tk.END, "❌ Unknown event - not found in database\n", "error")
            self.options_text.insert(tk.END, f"Searched for: '{event_name}'\n", "searched")
            
            # Cấu hình tags cho error
            self.options_text.tag_configure("error", foreground="#E74C3C", font=('Consolas', 11, 'bold'))
            self.options_text.tag_configure("searched", foreground="#95A5A6", font=('Consolas', 10))
            
            self.status_label.config(text="❌ Unknown event", foreground='#DC3545')

    def monitor_events(self):
        try:
            try:
                event_icon = pyautogui.locateCenterOnScreen("assets/icons/event_choice_1.png", confidence=0.8, minSearchTime=0.1)
            except ImageNotFoundException:
                event_icon = None
            if event_icon and self.event_detection_start is None:
                self.event_detection_start = time.time()
                self.status_label.config(text="👁️ Event detected, waiting for stability...", foreground='#FFC107')
            if event_icon and self.event_detection_start and not self.event_displayed:
                time_present = time.time() - self.event_detection_start
                if time_present >= 1.0:
                    self.status_label.config(text="✅ Processing event...", foreground='#17A2B8')
                    event_image = capture_region(self.event_region)
                    event_name = extract_event_name_text(event_image)
                    event_name = event_name.strip()
                    if event_name and event_name != self.last_event_name:
                        event_variations = self.generate_event_variations(event_name)
                        found_events = self.search_events(event_variations)
                        self.update_overlay(event_name, found_events)
                        self.last_event_name = event_name
                        self.event_displayed = True
                        self.event_detection_start = None
            elif not event_icon:
                if self.event_displayed:
                    self.event_displayed = False
                    self.last_event_name = None
                    self.status_label.config(text="🔄 Waiting for next event...", foreground='#6C757D')
                elif self.event_detection_start:
                    self.event_detection_start = None
                    self.status_label.config(text="❌ Event disappeared too quickly", foreground='#DC3545')
            self.root.after(500, self.monitor_events)
        except Exception as e:
            self.status_label.config(text=f"❌ Error: {str(e)}", foreground='#DC3545')
            self.root.after(500, self.monitor_events)

    def on_closing(self):
        print("🛑 Event overlay stopped by user")
        self.cleanup()
        self.root.destroy()

    def cleanup(self):
        """Khôi phục cửa sổ game về trạng thái ban đầu"""
        if self.game_window:
            try:
                print("🔄 Khôi phục cửa sổ game...")
                self.game_window.restore_window()
                print("✅ Đã khôi phục cửa sổ game")
            except Exception as e:
                print(f"⚠️ Lỗi khi khôi phục cửa sổ game: {str(e)}")

    def run(self):
        print("🎮 Event Overlay Started")
        print(f"📍 Overlay position: ({self.overlay_x}, {self.overlay_y})")
        print(f"📏 Overlay size: {self.overlay_width}x{self.overlay_height}")
        print("Press Ctrl+C or close the overlay window to stop")
        print()
        try:
            self.root.mainloop()
        except KeyboardInterrupt:
            self.on_closing()

def main():
    overlay = EventOverlay()
    overlay.run()

if __name__ == "__main__":
    main() 