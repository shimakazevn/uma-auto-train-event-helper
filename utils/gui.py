import tkinter as tk
from tkinter import ttk
import json
from tkinter import scrolledtext
import datetime

class BotGUI:
    def __init__(self, root, start_callback=None, stop_callback=None):
        self.root = root
        self.root.title("Uma Musume Auto Train")
        self.root.geometry("400x700")
        self.root.resizable(False, False)  # Disable window resizing
        
        # Prevent minimizing
        self.root.protocol("WM_DELETE_WINDOW", self._on_closing)
        
        # Set window to always on top
        self.root.attributes('-topmost', True)
        
        # Callbacks
        self.start_callback = start_callback
        self.is_running = False
        
        # Create notebook for tabs
        self.notebook = ttk.Notebook(root)
        self.notebook.pack(expand=True, fill='both', padx=5, pady=5)
        
        # Create main and config tabs
        self.main_tab = ttk.Frame(self.notebook)
        self.config_tab = ttk.Frame(self.notebook)
        
        self.notebook.add(self.main_tab, text='Bot')
        self.notebook.add(self.config_tab, text='Config')
        
        self._setup_main_tab()
        self._setup_config_tab()
        
        # Load config
        self.load_config()
    
    def _setup_main_tab(self):
        # Button frame at the top
        button_frame = ttk.Frame(self.main_tab)
        button_frame.pack(fill='x', padx=5, pady=5)
        
        # Start button
        self.start_button = ttk.Button(button_frame, text="Start", command=self._start_bot)
        self.start_button.pack(side='left', padx=5)

        # Log area taking most of the space
        self.log_area = scrolledtext.ScrolledText(
            self.main_tab,
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
    
    def _setup_config_tab(self):
        # Main config frame with scrollbar
        main_frame = ttk.Frame(self.config_tab)
        main_frame.pack(fill='both', expand=True, padx=5, pady=5)
        
        # Create canvas with scrollbar
        canvas = tk.Canvas(main_frame)
        scrollbar = ttk.Scrollbar(main_frame, orient="vertical", command=canvas.yview)
        self.config_frame = ttk.Frame(canvas)
        
        canvas.configure(yscrollcommand=scrollbar.set)
        
        # Pack scrollbar and canvas
        scrollbar.pack(side="right", fill="y")
        canvas.pack(side="left", fill="both", expand=True)
        
        # Create window in canvas
        canvas_frame = canvas.create_window((0,0), window=self.config_frame, anchor="nw")
        
        # Configure canvas scroll region when frame size changes
        def configure_scroll_region(event):
            canvas.configure(scrollregion=canvas.bbox("all"))
        self.config_frame.bind('<Configure>', configure_scroll_region)
        
        # Configure canvas width when window resizes
        def configure_canvas_width(event):
            canvas.itemconfig(canvas_frame, width=event.width)
        canvas.bind('<Configure>', configure_canvas_width)
        
        # Priority Stats Section
        self._create_section_label("Training Priority")
        self.priority_vars = []
        stats = ["Speed", "Stamina", "Power", "Guts", "Wisdom"]
        for i, stat in enumerate(stats):
            var = tk.StringVar(value=str(i+1))
            self._create_priority_entry(stat, var)
            self.priority_vars.append(var)
            
        # Basic Settings Section
        self._create_section_label("Basic Settings")
        
        # Minimum Mood
        self.mood_var = tk.StringVar(value="GOOD")
        mood_frame = ttk.Frame(self.config_frame)
        mood_frame.pack(fill='x', padx=10, pady=2)
        ttk.Label(mood_frame, text="Minimum Mood:").pack(side='left')
        mood_combo = ttk.Combobox(mood_frame, textvariable=self.mood_var, 
                                values=["GOOD", "NORMAL", "BAD"], width=10)
        mood_combo.pack(side='right')
        
        # Maximum Failures
        self.max_failure_var = tk.StringVar(value="15")
        self._create_number_entry("Maximum Failures", self.max_failure_var)
        
        # Skill Point Settings
        self._create_section_label("Skill Point Settings")
        
        self.skill_cap_var = tk.StringVar(value="1000")
        self._create_number_entry("Skill Point Cap", self.skill_cap_var)
        
        # Skill Point Check Options
        options_frame = ttk.Frame(self.config_frame)
        options_frame.pack(fill='x', padx=10, pady=2)
        
        self.enable_sp_check_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(options_frame, text="Enable Skill Point Check", 
                       variable=self.enable_sp_check_var).pack(side='left', padx=(0,10))
                       
        self.prioritize_g1_var = tk.BooleanVar(value=True)
        ttk.Checkbutton(options_frame, text="Prioritize G1 Race", 
                       variable=self.prioritize_g1_var).pack(side='left')
        
        # Race Settings
        self._create_section_label("Race Settings")
        
        self.min_support_var = tk.StringVar(value="0")
        self._create_number_entry("Minimum Support Rating", self.min_support_var)
        
        self.do_race_var = tk.BooleanVar(value=False)
        check_frame = ttk.Frame(self.config_frame)
        check_frame.pack(fill='x', padx=10, pady=2)
        ttk.Checkbutton(check_frame, text="Do Race When Bad Training", 
                       variable=self.do_race_var).pack(side='left')
        
        # Stat Caps Section
        self._create_section_label("Stat Caps")
        self.stat_caps = {}
        for stat in ["Speed", "Stamina", "Power", "Guts", "Wisdom"]:
            var = tk.StringVar(value="1100" if stat in ["Speed", "Stamina"] else "600")
            self._create_number_entry(f"{stat} Cap", var)
            self.stat_caps[stat.lower()[:3]] = var
            
        # Save Button
        save_frame = ttk.Frame(self.config_tab)
        save_frame.pack(fill='x', padx=5, pady=5)
        save_button = ttk.Button(save_frame, text="Save Config", command=self.save_config)
        save_button.pack(side='right')
    
    def _create_section_label(self, text):
        """Create a section header label"""
        label_frame = ttk.Frame(self.config_frame)
        label_frame.pack(fill='x', padx=5, pady=(10,5))
        label = ttk.Label(label_frame, text=text, font=('Helvetica', 10, 'bold'))
        label.pack(side='left')
        ttk.Separator(self.config_frame).pack(fill='x', padx=5)
        
    def _create_number_entry(self, label_text, var):
        """Create a labeled number entry"""
        frame = ttk.Frame(self.config_frame)
        frame.pack(fill='x', padx=10, pady=2)
        ttk.Label(frame, text=label_text + ":").pack(side='left')
        entry = ttk.Entry(frame, textvariable=var, width=10)
        entry.pack(side='right')
        
    def _create_priority_entry(self, stat_name, var):
        """Create a priority entry with up/down buttons"""
        frame = ttk.Frame(self.config_frame)
        frame.pack(fill='x', padx=10, pady=2)
        ttk.Label(frame, text=f"{stat_name} Priority:").pack(side='left')
        
        entry = ttk.Entry(frame, textvariable=var, width=5)
        entry.pack(side='right')
        
    def load_config(self):
        try:
            with open('config.json', 'r', encoding='utf-8') as f:
                config = json.load(f)
                
                # Load priority stats
                for i, stat in enumerate(['spd', 'sta', 'pwr', 'guts', 'wit']):
                    if i < len(config.get('priority_stat', [])):
                        self.priority_vars[i].set(str(i+1))
                
                # Load basic settings
                self.mood_var.set(config.get('minimum_mood', 'GOOD'))
                self.max_failure_var.set(str(config.get('maximum_failure', 15)))
                
                # Load skill point settings
                self.skill_cap_var.set(str(config.get('skill_point_cap', 1000)))
                self.enable_sp_check_var.set(config.get('enable_skill_point_check', True))
                self.prioritize_g1_var.set(config.get('prioritize_g1_race', True))
                
                # Load race settings
                self.min_support_var.set(str(config.get('min_support', 0)))
                self.do_race_var.set(config.get('do_race_when_bad_training', False))
                
                # Load stat caps
                stat_caps = config.get('stat_caps', {})
                for stat, var in self.stat_caps.items():
                    var.set(str(stat_caps.get(stat, 1100 if stat in ['spd', 'sta'] else 600)))
                
        except Exception as e:
            self.log(f"Error loading config: {str(e)}")
    
    def save_config(self):
        try:
            config = {
                'priority_stat': [s.lower()[:3] for s in ['Speed', 'Stamina', 'Power', 'Guts', 'Wisdom']],
                'minimum_mood': self.mood_var.get(),
                'maximum_failure': int(self.max_failure_var.get()),
                'prioritize_g1_race': self.prioritize_g1_var.get(),
                'skill_point_cap': int(self.skill_cap_var.get()),
                'enable_skill_point_check': self.enable_sp_check_var.get(),
                'min_support': int(self.min_support_var.get()),
                'do_race_when_bad_training': self.do_race_var.get(),
                'stat_caps': {
                    stat: int(var.get())
                    for stat, var in self.stat_caps.items()
                }
            }
            
            with open('config.json', 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=4)
            self.log("[SUCCESS] Config saved successfully")
        except Exception as e:
            self.log(f"[ERROR] Error saving config: {str(e)}")
    
    def _start_bot(self):
        if not self.is_running and self.start_callback:
            self.is_running = True
            self.start_button.configure(state='disabled')
            self.start_callback()
            self.log("Bot started successfully")
            self.log("please click into the game window to focus it")
            
    def _on_closing(self):
        """Handle window close event"""
        try:
            if not self.is_running:
                # Mark GUI as destroyed to prevent further log calls
                self.root.destroy()
            else:
                self.log("[WARNING] Please wait for the bot to finish...")
        except Exception as e:
            # If there's any error, just destroy the window
            try:
                self.root.destroy()
            except:
                pass

    def log(self, message, level='info', debug=False):
        """
        Add a message to the log similar to console output format.
        """
        try:
            # Check if log_area still exists
            if not hasattr(self, 'log_area') or not self.log_area.winfo_exists():
                print(message)
                return
                
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
            
        except tk.TclError:
            # Widget has been destroyed, fall back to print
            print(message)
        except Exception as e:
            # Any other error, fall back to print
            print(f"GUI log error: {e}")
            print(message)
