"""
Stellina Desktop Pet - Windows Interactive Preview Simulator
Simulatore in Python/Tkinter per testare fisica, animazioni e drag & drop su Windows.
Non richiede dipendenze esterne (usa solo librerie standard di Python).
"""

import os
import random
import sys
import tkinter as tk

def main():
    root = tk.Tk()
    root.title("Stellina Preview")

    # Configurazione finestra trasparente e borderless always-on-top
    root.overrideredirect(True)
    root.wm_attributes("-topmost", True)

    TRANS_COLOR = "#000001"
    root.configure(bg=TRANS_COLOR)
    root.wm_attributes("-transparentcolor", TRANS_COLOR)

    # Dimensioni
    TARGET_WIDTH = 150
    TARGET_HEIGHT = 150

    # Risoluzione dello schermo
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    ground_y = max(100, screen_height - TARGET_HEIGHT - 60)  # Sopra la taskbar di Windows

    # Forza encoding UTF-8 su console Windows se possibile
    if hasattr(sys.stdout, "reconfigure"):
        try:
            sys.stdout.reconfigure(encoding="utf-8")
        except Exception:
            pass

    # Individuazione cartella degli asset
    base_dir = os.path.dirname(os.path.abspath(__file__))
    candidates = [
        os.path.join(base_dir, "Assets Stellina"),
        os.path.join(base_dir, "Sources", "Stellina", "Resources", "Assets Stellina")
    ]
    assets_dir = None
    for cand in candidates:
        if os.path.exists(cand) and os.path.exists(os.path.join(cand, "Idle.png")):
            assets_dir = cand
            break

    if not assets_dir:
        print("[ERRORE] Cartella 'Assets Stellina' non trovata!")
        print(f"Cercato in: {candidates}")
        sys.exit(1)

    print(f"[*] Caricamento sprite da: {assets_dir}", flush=True)

    def load_scaled_image(filename):
        path = os.path.join(assets_dir, filename)
        if not os.path.exists(path):
            print(f"[!] Avviso: File {filename} mancante in {assets_dir}", flush=True)
            return None
        img = tk.PhotoImage(file=path)
        orig_w = img.width()
        sub = max(1, round(orig_w / TARGET_WIDTH))
        return img.subsample(sub, sub)

    images = {
        "idle": [load_scaled_image("Idle.png")],
        "walkLeft": [load_scaled_image("left1.png"), load_scaled_image("left2.png")],
        "walkRight": [load_scaled_image("right1.png"), load_scaled_image("right2.png")],
        "falling": [load_scaled_image("Fall.png")]
    }

    # Pulizia da eventuali None
    for k in images:
        images[k] = [img for img in images[k] if img is not None]
        if not images[k]:
            images[k] = images.get("idle", [])

    print(f"[OK] Sprite pronti: Idle={len(images['idle'])}, Left={len(images['walkLeft'])}, Right={len(images['walkRight'])}, Fall={len(images['falling'])}", flush=True)
    print(f"[*] Stellina e' attiva al centro dello schermo (X={int((screen_width - TARGET_WIDTH)/2)}, Y=80) e atterra a terra (Y={ground_y})!", flush=True)
    print("[*] Trascinala con il mouse o clicca tasto destro su di essa per il menu.", flush=True)

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

    # Parametri di fisica e stato
    state = {
        "pos_x": (screen_width - TARGET_WIDTH) / 2.0,
        "pos_y": 50.0,
        "velocity_y": 0.0,
        "gravity": 2.0,
        "walk_speed": 4.0,
        "current_state": "falling",
        "walk_ticks": 0,
        "anim_index": 0,
        "anim_counter": 0,
        "anim_speed": 5,
        "is_dragging": False,
        "drag_offset_x": 0,
        "drag_offset_y": 0
    }

    # Posizionamento iniziale finestra
    root.geometry(f"{TARGET_WIDTH}x{TARGET_HEIGHT}+{int(state['pos_x'])}+{int(state['pos_y'])}")

    # Gestione Drag and Drop con il Mouse
    def on_mouse_down(event):
        state["is_dragging"] = True
        state["current_state"] = "falling"
        state["velocity_y"] = 0.0
        state["drag_offset_x"] = event.x
        state["drag_offset_y"] = event.y

    def on_mouse_drag(event):
        if state["is_dragging"]:
            current_x = root.winfo_x() + event.x - state["drag_offset_x"]
            current_y = root.winfo_y() + event.y - state["drag_offset_y"]
            state["pos_x"] = current_x
            state["pos_y"] = current_y
            root.geometry(f"+{int(current_x)}+{int(current_y)}")

    def on_mouse_up(event):
        state["is_dragging"] = False
        if state["pos_y"] >= ground_y:
            state["pos_y"] = ground_y
            state["current_state"] = "idle"
            state["walk_ticks"] = random.randint(60, 150)
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
        root.geometry(f"+{int(state['pos_x'])}+{int(state['pos_y'])}")

    context_menu.add_command(label="🐾 Stellina Preview (Windows)", state="disabled")
    context_menu.add_separator()
    context_menu.add_command(label="Riposiziona al Centro", command=reset_pos)
    context_menu.add_separator()
    context_menu.add_command(label="Chiudi Stellina", command=root.destroy)

    def on_right_click(event):
        context_menu.tk_popup(event.x_root, event.y_root)

    canvas.bind("<Button-3>", on_right_click)

    # Loop di fisica e animazione (~30 FPS)
    def update_physics():
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
            else:
                state["pos_y"] = ground_y
                state["velocity_y"] = 0.0

                # Movimento a terra
                if state["walk_ticks"] > 0:
                    state["walk_ticks"] -= 1
                    if state["current_state"] == "walkRight":
                        state["pos_x"] += state["walk_speed"]
                    elif state["current_state"] == "walkLeft":
                        state["pos_x"] -= state["walk_speed"]

                    # Rimbalzo sui bordi
                    if state["pos_x"] < 0:
                        state["pos_x"] = 0
                        state["current_state"] = "walkRight"
                    elif state["pos_x"] > screen_width - TARGET_WIDTH:
                        state["pos_x"] = screen_width - TARGET_WIDTH
                        state["current_state"] = "walkLeft"
                else:
                    # Nuova azione
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

        root.after(33, update_physics)

    root.after(33, update_physics)
    root.mainloop()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
