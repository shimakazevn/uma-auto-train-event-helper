import tkinter as tk
from tkinter import ttk
import json
import threading
from tkinter import scrolledtext
import datetime
import keyboard

class BotGUI:
    def __init__(self, root, start_callback=None, stop_callback=None):
        self.root = root
        self.root.title("Uma Musume Auto Train")
        self.root.geometry("500x1000")
        
        # Handle window close
        self.root.protocol("WM_DELETE_WINDOW", self._on_closing)
        
        # Set window to always on top
        self.root.attributes('-topmost', True)
        
        # Add pin/unpin button state
        self.is_pinned = True
        
        # Callbacks
        self.start_callback = start_callback
        self.stop_callback = stop_callback
        self.is_running = False
        
        # Bind Ctrl+C to stop bot (both in GUI and globally)
        self.root.bind('<Control-c>', self._handle_stop_hotkey)
        keyboard.add_hotkey('ctrl+c', self._handle_stop_hotkey)
        
        # Create main container frame
        self.main_frame = ttk.Frame(root)
        self.main_frame.pack(expand=True, fill='both', padx=5, pady=5)
        
        # Create control and config frames
        self.control_frame = ttk.Frame(self.main_frame)
        self.control_frame.pack(expand=True, fill='both')
        self.config_frame = ttk.Frame(self.main_frame)
        
        self._setup_control_tab()
        self._setup_config_tab()
        
        # Load config
        self.load_config()
    
    def _setup_control_tab(self):
        # Button frame at the top
        button_frame = ttk.Frame(self.control_frame)
        button_frame.pack(fill='x', padx=5, pady=5)
        
        # Start button
        self.start_button = ttk.Button(button_frame, text="Start", command=self._start_bot)
        self.start_button.pack(side='left', padx=5)
        
        # Stop button (initially disabled)
        self.stop_button = ttk.Button(button_frame, text="Stop", command=self._stop_bot, state='disabled')
        self.stop_button.pack(side='left', padx=5)
        
        # Pin button
        self.pin_button = ttk.Button(button_frame, text="Unpin", command=self._toggle_pin)
        self.pin_button.pack(side='right', padx=5)
        
        # Config button
        self.config_button = ttk.Button(button_frame, text="Config", command=self._toggle_config)
        self.config_button.pack(side='right', padx=5)
        
        # Log area taking most of the space
        self.log_area = scrolledtext.ScrolledText(
            self.control_frame,
            wrap=tk.WORD,
            height=45,  # Increased height for more visible logs
            font=('Consolas', 10),
            background='#1E1E1E',  # Dark background like VS Code
            foreground='#CCCCCC',  # Light grey text for better readability
        )
        self.log_area.pack(fill='both', expand=True, padx=5, pady=5)
        
        # Configure tags for different message types
        self.log_area.tag_configure('error', foreground='#F14C4C')      # Bright red
        self.log_area.tag_configure('warning', foreground='#CCA700')    # Amber
        self.log_area.tag_configure('success', foreground='#73C991')    # Green
        self.log_area.tag_configure('info', foreground='#75BEFF')       # Light blue
        self.log_area.tag_configure('debug', foreground='#B180D7')      # Purple
    
    def _toggle_config(self):
        """Toggle between main log view and config view"""
        if self.config_frame.winfo_ismapped():
            self.config_frame.pack_forget()
            self.control_frame.pack(expand=True, fill='both')
            self.config_button.configure(text="Config")
        else:
            self.control_frame.pack_forget()
            self.config_frame.pack(expand=True, fill='both')
            self.config_button.configure(text="Back")

    def _setup_config_tab(self):
        # Config editor with dark theme
        self.config_editor = scrolledtext.ScrolledText(
            self.config_frame,
            wrap=tk.WORD,
            height=45,
            font=('Consolas', 10),
            background='#1E1E1E',
            foreground='#CCCCCC',
        )
        self.config_editor.pack(fill='both', expand=True, padx=5, pady=5)
        
        # Save button frame
        button_frame = ttk.Frame(self.config_frame)
        button_frame.pack(fill='x', padx=5, pady=5)
        
        # Save button
        save_button = ttk.Button(button_frame, text="Save Config", command=self.save_config)
        save_button.pack(side='right', padx=5)
    
    def load_config(self):
        try:
            with open('config.json', 'r', encoding='utf-8') as f:
                config = json.load(f)
                formatted_config = json.dumps(config, indent=4)
                self.config_editor.delete('1.0', tk.END)
                self.config_editor.insert('1.0', formatted_config)
        except Exception as e:
            self.log(f"Error loading config: {str(e)}")
    
    def save_config(self):
        try:
            config_text = self.config_editor.get('1.0', tk.END).strip()
            config = json.loads(config_text)
            with open('config.json', 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=4)
            self.log("Config saved successfully")
        except Exception as e:
            self.log(f"Error saving config: {str(e)}")
    
    def _start_bot(self):
        if not self.is_running and self.start_callback:
            self.is_running = True
            self.start_button.configure(state='disabled')
            self.stop_button.configure(state='normal')
            self.start_callback()
            self.log("Bot started successfully")
            self.log( "please click into the game window to focus it")
    def _handle_stop_hotkey(self, event=None):
        """Handle stop hotkey (Ctrl+C) from both GUI and global keyboard"""
        if self.is_running:
            self._stop_bot()
    
    def _stop_bot(self):
        """Stop the bot and update UI"""
        if not self.is_running:
            return
            
        try:
            # Call stop callback first
            if self.stop_callback:
                self.stop_callback()
            
            # Then update UI
            self.is_running = False
            self.start_button.configure(state='normal')
            self.stop_button.configure(state='disabled')
            self.root.focus_force()  # Focus the GUI window
            self.log("Bot stopped (Press Ctrl+C or Stop button to stop again)")
        except Exception as e:
            self.log(f"[ERROR] Error stopping bot: {str(e)}")
    
    def _toggle_pin(self):
        self.is_pinned = not self.is_pinned
        self.root.attributes('-topmost', self.is_pinned)
        self.pin_button.configure(text="Unpin" if self.is_pinned else "Pin")
        self.log("Window " + ("pinned" if self.is_pinned else "unpinned"))
            
    def _on_closing(self):
        """Handle window close event"""
        # Remove global hotkey
        keyboard.remove_hotkey('ctrl+c')
        # Stop bot if running
        if self.is_running:
            self._stop_bot()
        # Destroy window
        self.root.destroy()

    def log(self, message, level='info', debug=False):
        """
        Add a message to the log similar to console output format.
        """
        # Determine message level and format from the content
        msg_level = 'info'
        log_text = message

        # Check if message starts with a level indicator
        if message.startswith('[WARNING]'):
            msg_level = 'warning'
        elif message.startswith('[ERROR]'):
            msg_level = 'error'
        elif message.startswith('[INFO]'):
            msg_level = 'info'
        elif message.startswith('=='):
            msg_level = 'success'
            log_text = f"\n{message}"
        else:
            # For messages without level prefix, detect type from content
            if any([
                "OCR:" in message,
                "confidence:" in message.lower(),
                "ratio:" in message.lower(),
                "Analyzing" in message,
                "->" in message and "{" in message,
                "Current stats:" in message
            ]):
                msg_level = 'debug'
            elif "WARNING" in message:
                msg_level = 'warning'
            elif "ERROR" in message:
                msg_level = 'error'
            elif any([
                "SUCCESS" in message,
                "Year:" in message,
                "Best training:" in message
            ]):
                msg_level = 'success'

        # Add newline if not present
        if not log_text.endswith('\n'):
            log_text += '\n'
            
        # Write to log area
        self.log_area.insert(tk.END, log_text, msg_level)
        # Keep only last 1000 lines
        content = self.log_area.get('1.0', tk.END).splitlines()
        if len(content) > 1000:
            self.log_area.delete('1.0', f"{len(content)-1000}.0")
        self.log_area.see(tk.END)
