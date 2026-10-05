"""
Stellina Desktop Pet - Windows Version
Implementazione per Windows con:
- Finestra trasparente floating e borderless
- Gravità, atterraggio e rimbalzo ai bordi
- Rilevamento gesture Pat-Pat (carezze con il mouse)
- Particelle procedurali di cuoricini ❤️ e zzz 💤
- Fisica elastica cartoon (Squish & Stretch)
- Modalità sonno (Sleep Mode) per inattività
- Effetti sonori procedurali delicati (winsound / multithreaded)
"""

import math
import os
import random
import sys
import threading
import tkinter as tk

try:
    import winsound
    HAS_WINSOUND = True
except ImportError:
    HAS_WINSOUND = False

# Encoding UTF-8 per console Windows
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass


class SoundPlayer:
    def __init__(self):
        self.enabled = True

    def _play_async(self, func):
        if not self.enabled or not HAS_WINSOUND:
            return
        threading.Thread(target=func, daemon=True).start()

    def play_pat_pat(self):
        def _sound():
            try:
                for freq in [520, 650, 780]:
                    winsound.Beep(freq, 40)
            except Exception:
                pass
        self._play_async(_sound)

    def play_drag(self):
        def _sound():
            try:
                winsound.Beep(750, 30)
            except Exception:
                pass
        self._play_async(_sound)

    def play_land(self):
        def _sound():
            try:
                winsound.Beep(240, 45)
            except Exception:
                pass
        self._play_async(_sound)

    def play_wake(self):
        def _sound():
            try:
                winsound.Beep(587, 50)
                winsound.Beep(880, 70)
            except Exception:
                pass
        self._play_async(_sound)


def main():
    root = tk.Tk()
    root.title("Stellina Desktop Pet")

    # Configurazione finestra trasparente e borderless always-on-top
    root.overrideredirect(True)
    root.wm_attributes("-topmost", True)

    TRANS_COLOR = "#000001"
    root.configure(bg=TRANS_COLOR)
    root.wm_attributes("-transparentcolor", TRANS_COLOR)

    # Dimensioni base
    TARGET_WIDTH = 150
    TARGET_HEIGHT = 150

    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    ground_y = max(100, screen_height - TARGET_HEIGHT - 60)

    # Individuazione cartella degli asset (supporta esecuzione diretta e PyInstaller bundle)
    base_dir = getattr(sys, "_MEIPASS", os.path.dirname(os.path.abspath(__file__)))
    project_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    exe_dir = os.path.dirname(sys.executable)

    candidates = [
        os.path.join(base_dir, "Assets Stellina"),
        os.path.join(project_root, "Assets Stellina"),
        os.path.join(project_root, "Sources", "Stellina", "Resources", "Assets Stellina"),
        os.path.join(exe_dir, "Assets Stellina"),
        os.path.join(os.getcwd(), "Assets Stellina")
    ]
    assets_dir = None
    for cand in candidates:
        if os.path.exists(cand) and os.path.exists(os.path.join(cand, "Idle.png")):
            assets_dir = cand
            break

    if not assets_dir:
        print("[ERRORE] Cartella 'Assets Stellina' non trovata!", file=sys.stderr)
        sys.exit(1)

    print(f"[*] Caricamento sprite da: {assets_dir}", flush=True)

    def load_scaled_image(filename):
        path = os.path.join(assets_dir, filename)
        if not os.path.exists(path):
            return None
        img = tk.PhotoImage(file=path)
        orig_w = img.width()
        orig_h = img.height()
        sub = max(1, round(max(orig_w / TARGET_WIDTH, orig_h / TARGET_HEIGHT)))
        return img.subsample(sub, sub)

    images = {
        "idle": [load_scaled_image("Idle.png")],
        "walkLeft": [load_scaled_image("left1.png"), load_scaled_image("left2.png")],
        "walkRight": [load_scaled_image("right1.png"), load_scaled_image("right2.png")],
        "falling": [load_scaled_image("Fall.png")],
        "sleeping": [load_scaled_image("Sleep.png")]
    }

    for k in images:
        images[k] = [img for img in images[k] if img is not None]
        if not images[k]:
            images[k] = images.get("idle", [])

    sound_player = SoundPlayer()

    # Canvas trasparente
    canvas = tk.Canvas(
        root,
        width=TARGET_WIDTH,
        height=TARGET_HEIGHT,
        bg=TRANS_COLOR,
        highlightthickness=0
    )
    canvas.pack(fill="both", expand=True)

    pet_sprite = canvas.create_image(
        TARGET_WIDTH // 2,
        TARGET_HEIGHT // 2,
        image=images["idle"][0] if images["idle"] else ""
    )

    # Parametri di fisica, animazione e stato comportamentale
    state = {
        "pos_x": (screen_width - TARGET_WIDTH) / 2.0,
        "pos_y": 50.0,
        "velocity_y": 0.0,
        "gravity": 2.0,
        "walk_speed": 4.0,
        "current_state": "falling",
        "walk_ticks": 0,
        "petted_ticks": 0,
        "inactivity_ticks": 0,
        "anim_index": 0,
        "anim_counter": 0,
        "anim_speed": 5,
        "is_dragging": False,
        "drag_offset_x": 0,
        "drag_offset_y": 0,
        "squish_ticks": 0,
        "wobble_angle": 0.0
    }

    # Sistema particellare procedurale (Cuori ❤️ e Zzz 💤)
    particles = []

    def spawn_particle(text, color="#FF4081", size=16, offset_x=None, offset_y=None):
        ox = offset_x if offset_x is not None else random.randint(30, TARGET_WIDTH - 30)
        oy = offset_y if offset_y is not None else random.randint(40, TARGET_HEIGHT - 30)
        p_id = canvas.create_text(
            ox,
            oy,
            text=text,
            fill=color,
            font=("Segoe UI Emoji", size, "bold")
        )
        particles.append({
            "id": p_id,
            "x": float(ox),
            "y": float(oy),
            "vx": random.uniform(-0.6, 0.6),
            "vy": random.uniform(-1.5, -2.5),
            "life": 28
        })

    def update_particles():
        to_remove = []
        for p in particles:
            p["x"] += p["vx"]
            p["y"] += p["vy"]
            p["life"] -= 1
            canvas.coords(p["id"], p["x"], p["y"])
            if p["life"] <= 0:
                canvas.delete(p["id"])
                to_remove.append(p)
        for p in to_remove:
            particles.remove(p)

    def trigger_pet():
        state["inactivity_ticks"] = 0
        if state["current_state"] == "sleeping":
            wake_up()
            return
        state["current_state"] = "petted"
        state["petted_ticks"] = 45  # ~1.5 secondi di coccole
        sound_player.play_pat_pat()
        # Genera una pioggia di cuoricini fluttuanti
        for i in range(3):
            root.after(i * 120, lambda: spawn_particle("❤️", color="#FF3366", size=18))

    def wake_up():
        if state["current_state"] == "sleeping":
            state["current_state"] = "idle"
            state["inactivity_ticks"] = 0
            state["walk_ticks"] = 40
            sound_player.play_wake()
            spawn_particle("✨", color="#FFD700", size=20, offset_x=TARGET_WIDTH//2, offset_y=30)
            # Piccolo saltino di risveglio
            state["velocity_y"] = -6.0

    # Rilevatore Pat-Pat (movimento cursore avanti e indietro)
    pat_detector = {
        "last_x": 0,
        "last_time": 0,
        "strokes": 0,
        "last_dir": 0
    }

    def on_mouse_motion(event):
        state["inactivity_ticks"] = 0
        if state["current_state"] == "sleeping":
            wake_up()
            return

        now = root.tk.call("clock", "milliseconds")
        dx = event.x - pat_detector["last_x"]

        if abs(dx) > 4:
            current_dir = 1 if dx > 0 else -1
            time_diff = (now - pat_detector["last_time"]) / 1000.0

            if current_dir != pat_detector["last_dir"] and time_diff < 0.6:
                pat_detector["strokes"] += 1
                if pat_detector["strokes"] >= 3:
                    pat_detector["strokes"] = 0
                    trigger_pet()
            elif time_diff > 0.8:
                pat_detector["strokes"] = 1

            pat_detector["last_dir"] = current_dir
            pat_detector["last_time"] = now
            pat_detector["last_x"] = event.x

    canvas.bind("<Motion>", on_mouse_motion)

    # Posizionamento iniziale finestra
    root.geometry(f"{TARGET_WIDTH}x{TARGET_HEIGHT}+{int(state['pos_x'])}+{int(state['pos_y'])}")

    # Gestione Drag and Drop con il Mouse
    def on_mouse_down(event):
        state["inactivity_ticks"] = 0
        if state["current_state"] == "sleeping":
            wake_up()
            return

        state["is_dragging"] = True
        state["current_state"] = "falling"
        state["velocity_y"] = 0.0
        state["drag_offset_x"] = event.x
        state["drag_offset_y"] = event.y
        sound_player.play_drag()

    def on_mouse_drag(event):
        if state["is_dragging"]:
            current_x = root.winfo_x() + event.x - state["drag_offset_x"]
            current_y = root.winfo_y() + event.y - state["drag_offset_y"]
            state["pos_x"] = current_x
            state["pos_y"] = current_y
            root.geometry(f"+{int(current_x)}+{int(current_y)}")

    def on_mouse_up(event):
        state["is_dragging"] = False
        state["inactivity_ticks"] = 0
        if state["pos_y"] >= ground_y:
            state["pos_y"] = ground_y
            state["current_state"] = "idle"
            state["walk_ticks"] = random.randint(60, 150)
            state["squish_ticks"] = 6
            sound_player.play_land()
        else:
            state["current_state"] = "falling"

    canvas.bind("<Button-1>", on_mouse_down)
    canvas.bind("<B1-Motion>", on_mouse_drag)
    canvas.bind("<ButtonRelease-1>", on_mouse_up)

    # Menu contestuale tasto destro
    context_menu = tk.Menu(root, tearoff=0)

    def reset_pos():
        state["pos_x"] = (screen_width - TARGET_WIDTH) / 2.0
        state["pos_y"] = 50.0
        state["velocity_y"] = 0.0
        state["current_state"] = "falling"
        state["inactivity_ticks"] = 0
        root.geometry(f"+{int(state['pos_x'])}+{int(state['pos_y'])}")

    def toggle_sound():
        sound_player.enabled = not sound_player.enabled
        lbl = "🔊 Audio: Attivo" if sound_player.enabled else "🔇 Audio: Disattivo"
        context_menu.entryconfigure(2, label=lbl)

    def force_sleep():
        state["current_state"] = "sleeping"
        state["velocity_y"] = 0.0
        state["pos_y"] = ground_y

    context_menu.add_command(label="🐾 Stellina Desktop Pet", state="disabled")
    context_menu.add_command(label="💖 Fai le Coccole (Pat-Pat)", command=trigger_pet)
    context_menu.add_command(label="💤 Metti a Dormire", command=force_sleep)
    context_menu.add_command(label="🔊 Audio: Attivo", command=toggle_sound)
    context_menu.add_separator()
    context_menu.add_command(label="Riposiziona al Centro", command=reset_pos)
    context_menu.add_separator()
    context_menu.add_command(label="Chiudi Stellina", command=root.destroy)

    def on_right_click(event):
        context_menu.tk_popup(event.x_root, event.y_root)

    canvas.bind("<Button-3>", on_right_click)

    # Loop di fisica, animazione e comportamenti (~30 FPS)
    def update_physics():
        update_particles()

        if not state["is_dragging"]:
            # Gravità
            if state["pos_y"] < ground_y:
                state["velocity_y"] += state["gravity"]
                state["pos_y"] += state["velocity_y"]
                if state["pos_y"] >= ground_y:
                    state["pos_y"] = ground_y
                    state["velocity_y"] = 0.0
                    state["current_state"] = "idle"
                    state["walk_ticks"] = random.randint(60, 150)
                    state["anim_index"] = 0
                    state["squish_ticks"] = 6
                    sound_player.play_land()
            else:
                state["pos_y"] = ground_y
                state["velocity_y"] = 0.0

                if state["current_state"] == "petted":
                    state["petted_ticks"] -= 1
                    if state["petted_ticks"] <= 0:
                        state["current_state"] = "idle"
                        state["walk_ticks"] = random.randint(50, 100)
                elif state["current_state"] == "sleeping":
                    # Emetti periodicamente le bolle ZzZz
                    if random.random() < 0.08:
                        zzz_text = random.choice(["z", "Zz", "ZzZz", "💤"])
                        spawn_particle(
                            zzz_text,
                            color=random.choice(["#5C6BC0", "#7986CB", "#9FA8DA"]),
                            size=random.randint(14, 20),
                            offset_x=TARGET_WIDTH // 2 + random.randint(-15, 20),
                            offset_y=TARGET_HEIGHT // 2 - 20
                        )
                else:
                    # Inattività verso lo stato di sonno (~45 secondi a 30 FPS = 1350 ticks)
                    state["inactivity_ticks"] += 1
                    if state["inactivity_ticks"] > 1350:
                        state["current_state"] = "sleeping"

                    # Movimento a terra
                    if state["current_state"] != "sleeping":
                        if state["walk_ticks"] > 0:
                            state["walk_ticks"] -= 1
                            if state["current_state"] == "walkRight":
                                state["pos_x"] += state["walk_speed"]
                            elif state["current_state"] == "walkLeft":
                                state["pos_x"] -= state["walk_speed"]

                            # Rimbalzo sui bordi schermo
                            if state["pos_x"] < 0:
                                state["pos_x"] = 0
                                state["current_state"] = "walkRight"
                            elif state["pos_x"] > screen_width - TARGET_WIDTH:
                                state["pos_x"] = screen_width - TARGET_WIDTH
                                state["current_state"] = "walkLeft"
                        else:
                            # Nuova azione casuale
                            r = random.randint(1, 3)
                            if r == 1:
                                state["current_state"] = "idle"
                            elif r == 2:
                                state["current_state"] = "walkRight"
                            else:
                                state["current_state"] = "walkLeft"
                            state["walk_ticks"] = random.randint(60, 150)
                            state["anim_index"] = 0

            # Aggiorna posizione finestra
            root.geometry(f"+{int(state['pos_x'])}+{int(state['pos_y'])}")

        # Avanzamento animazione frame
        state["anim_counter"] += 1
        current_frames = images.get(state["current_state"], images["idle"])
        if state["anim_counter"] >= state["anim_speed"]:
            state["anim_counter"] = 0
            if current_frames:
                state["anim_index"] = (state["anim_index"] + 1) % len(current_frames)

        if current_frames:
            cur_img = current_frames[state["anim_index"] % len(current_frames)]
            canvas.itemconfig(pet_sprite, image=cur_img)

        # Effetto procedurale Squish & Stretch e Purr Wobble
        sprite_x = TARGET_WIDTH // 2
        sprite_y = TARGET_HEIGHT // 2

        if state["squish_ticks"] > 0:
            # All'atterraggio si schiaccia leggermente
            state["squish_ticks"] -= 1
            sprite_y += 6
        elif state["is_dragging"]:
            # Allungamento cartoon verso l'alto
            sprite_y -= 4
        elif state["current_state"] == "petted":
            # Oscillazione gioiosa (wobble fusa)
            state["wobble_angle"] += 0.4
            sprite_x += int(math.sin(state["wobble_angle"]) * 3.5)
        elif state["current_state"] == "sleeping":
            # Accucciata a terra
            sprite_y += 8

        canvas.coords(pet_sprite, sprite_x, sprite_y)

        root.after(33, update_physics)

    print("[*] Stellina Desktop Pet e' attiva!", flush=True)
    print("    - Passa il cursore velocemente sopra di lei per farle le coccole (Pat-Pat) ❤️", flush=True)
    print("    - Lasciala riposare e si addormentera' con le bollicine Zzz 💤", flush=True)
    print("    - Clic destro per il menu opzioni e toggle audio 🔊", flush=True)

    root.after(33, update_physics)
    root.mainloop()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
