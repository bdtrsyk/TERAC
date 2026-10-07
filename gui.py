"""
LumenMAX: PyQt6 Graphical User Interface
========================================
Interactive platform for the LumenMAX Custom Discrete Ternary Cognitive Architecture.

Menus:
1. Chatting & Dynamic Reasoning:
   - Real-time token streaming from ternary state dynamics.
   - Zero hardcoded questions or answers.
   - Live telemetry: Active Expert, Halting Confidence, Reasoning Cycles, Gate Activity.
2. Discrete Training & Synaptic Ecology:
   - Interactive training on custom or 60/20/20 cognitive benchmark dataset.
   - Real-time parameter mutation tracking, epoch progress, and accuracy.
   - Synapse Parameter Accountability Explorer & Group Competition Monitor.
"""

import sys
import time
import numpy as np
from typing import List, Dict, Any, Optional

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QTabWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QTextEdit, QLineEdit, QPushButton, QProgressBar, QTableWidget,
    QTableWidgetItem, QSpinBox, QComboBox, QGroupBox, QSplitter, QHeaderView,
    QMessageBox, QFrame
)
from PyQt6.QtCore import Qt, QThread, pyqtSignal
from PyQt6.QtGui import QFont, QColor

from lumenmax import LumenMAX, build_benchmark_dataset, inspect_ternary_distribution, inspect_parameter_accountability, inspect_group_competition

# ============================================================
# WORKER THREADS (Non-blocking GUI)
# ============================================================

class ChatWorker(QThread):
    step_ready = pyqtSignal(dict)
    finished = pyqtSignal(str)

    def __init__(self, model: LumenMAX, prompt: str, max_tokens: int = 12, task_type: str = "code"):
        super().__init__()
        self.model = model
        self.prompt = prompt
        self.max_tokens = max_tokens
        self.task_type = task_type

    def run(self):
        resp, telemetry = self.model.generate_sequence(self.prompt, max_new_tokens=self.max_tokens, task_type=self.task_type)
        for t in telemetry:
            self.step_ready.emit(t)
            time.sleep(0.04)  # Small visual delay for observing dynamic reasoning
        self.finished.emit(resp)


class TrainingWorker(QThread):
    epoch_progress = pyqtSignal(int, int, float, float) # epoch, total, acc, avg_cycles
    training_complete = pyqtSignal(dict)

    def __init__(self, model: LumenMAX, dataset: List[Dict[str, Any]], epochs: int):
        super().__init__()
        self.model = model
        self.dataset = dataset
        self.epochs = epochs

    def run(self):
        t0 = time.time()
        final_acc = 0.0
        for ep in range(self.epochs):
            correct = 0
            total_cycles = 0
            for ex in self.dataset:
                res = self.model.train_example(ex['input'], ex['target'], task_type=ex['category'])
                if res['verified']:
                    correct += 1
                total_cycles += res['cycles']
            acc = correct / len(self.dataset)
            avg_cyc = total_cycles / len(self.dataset)
            final_acc = acc
            self.epoch_progress.emit(ep + 1, self.epochs, acc, avg_cyc)
            time.sleep(0.02)
            
        elapsed = time.time() - t0
        self.training_complete.emit({
            'epochs': self.epochs,
            'final_acc': final_acc,
            'elapsed': elapsed
        })


# ============================================================
# MAIN GUI WINDOW
# ============================================================

class LumenMAXGUI(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("LumenMAX - Ternary Cognitive Intelligence Platform")
        self.resize(1150, 780)
        
        # Initialize discrete cognitive model
        self.model = LumenMAX(state_dim=32, input_dim=32, vocab_size=64, seed=42)
        self.dataset = build_benchmark_dataset()
        
        self._init_ui()
        self._apply_dark_theme()

    def _init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(12, 12, 12, 12)
        main_layout.setSpacing(10)
        
        # Header Banner
        header = QFrame()
        header.setObjectName("HeaderFrame")
        header_layout = QHBoxLayout(header)
        header_layout.setContentsMargins(15, 10, 15, 10)
        
        title_label = QLabel("⚡ LumenMAX: Custom Discrete Ternary Cognitive Architecture")
        title_label.setFont(QFont("Segoe UI", 14, QFont.Weight.Bold))
        
        status_label = QLabel("W ∈ {-1,0,+1} | Zero-Gradient | Custom Ternary SSM | Discrete Halting")
        status_label.setStyleSheet("color: #a6e3a1; font-weight: bold;")
        
        header_layout.addWidget(title_label)
        header_layout.addStretch()
        header_layout.addWidget(status_label)
        main_layout.addWidget(header)
        
        # Two Main Menus (Tabs)
        self.tabs = QTabWidget()
        self.tabs.setFont(QFont("Segoe UI", 11, QFont.Weight.DemiBold))
        
        # Tab 1: Chatting & Dynamic Reasoning
        self.chat_tab = QWidget()
        self._setup_chat_tab()
        self.tabs.addTab(self.chat_tab, "💬 1. Dynamic Cognitive Chatting")
        
        # Tab 2: Discrete Training & Synaptic Ecology
        self.train_tab = QWidget()
        self._setup_train_tab()
        self.tabs.addTab(self.train_tab, "🧠 2. Discrete Training & Synapses")
        
        main_layout.addWidget(self.tabs)

    # ------------------------------------------------------------
    # TAB 1: CHATTING & REASONING (NO HARDCODED Q&A)
    # ------------------------------------------------------------
    def _setup_chat_tab(self):
        layout = QHBoxLayout(self.chat_tab)
        layout.setContentsMargins(10, 10, 10, 10)
        layout.setSpacing(12)
        
        splitter = QSplitter(Qt.Orientation.Horizontal)
        
        # Left Panel: Live Chat
        chat_panel = QWidget()
        chat_layout = QVBoxLayout(chat_panel)
        chat_layout.setContentsMargins(0, 0, 0, 0)
        
        info_banner = QLabel("ℹ️ LumenMAX has NO hardcoded Q&A. Every token is computed dynamically via ternary synaptic dot products and persistent state recurrence.")
        info_banner.setWordWrap(True)
        info_banner.setStyleSheet("color: #89b4fa; padding: 6px; background: #181825; border-radius: 4px;")
        chat_layout.addWidget(info_banner)
        
        self.chat_history = QTextEdit()
        self.chat_history.setReadOnly(True)
        self.chat_history.setFont(QFont("Consolas", 10))
        chat_layout.addWidget(self.chat_history)
        
        # Prompt Input Row
        input_row = QHBoxLayout()
        self.input_field = QLineEdit()
        self.input_field.setPlaceholderText("Enter prompt (e.g. 'def x', '1 + 2', 'REQ SPEC', or any text)...")
        self.input_field.setFont(QFont("Consolas", 11))
        self.input_field.returnPressed.connect(self._send_chat_message)
        
        self.task_selector = QComboBox()
        self.task_selector.addItems(["code", "math", "structured"])
        
        self.send_btn = QPushButton("Reason & Send")
        self.send_btn.setFont(QFont("Segoe UI", 10, QFont.Weight.Bold))
        self.send_btn.clicked.connect(self._send_chat_message)
        
        self.clear_chat_btn = QPushButton("Reset State")
        self.clear_chat_btn.clicked.connect(self._reset_chat_state)
        
        input_row.addWidget(self.input_field, stretch=4)
        input_row.addWidget(QLabel("Domain:"))
        input_row.addWidget(self.task_selector)
        input_row.addWidget(self.send_btn)
        input_row.addWidget(self.clear_chat_btn)
        chat_layout.addLayout(input_row)
        
        splitter.addWidget(chat_panel)
        
        # Right Panel: Cognitive Telemetry
        telemetry_panel = QGroupBox("🔍 Real-Time Cognitive Telemetry")
        telemetry_layout = QVBoxLayout(telemetry_panel)
        
        self.expert_label = QLabel("Active Expert: None")
        self.expert_label.setStyleSheet("color: #f9e2af; font-size: 13px; font-weight: bold;")
        
        self.confidence_label = QLabel("Halting Confidence: Standby")
        self.confidence_label.setStyleSheet("color: #a6e3a1; font-size: 13px; font-weight: bold;")
        
        self.cycles_label = QLabel("Reasoning Depth: 0 cycles")
        self.state_norm_label = QLabel("Active Ternary State Norm: 0 / 32")
        self.loop_label = QLabel("Repetition Loop Status: Clear")
        self.gate_label = QLabel("3-Way Gate Activity: Standby")
        
        telemetry_layout.addWidget(self.expert_label)
        telemetry_layout.addWidget(self.confidence_label)
        telemetry_layout.addWidget(self.cycles_label)
        telemetry_layout.addWidget(self.state_norm_label)
        telemetry_layout.addWidget(self.loop_label)
        telemetry_layout.addWidget(self.gate_label)
        telemetry_layout.addStretch()
        
        # Live State Inspector
        telemetry_layout.addWidget(QLabel("Persistent State S_t in {-1, 0, +1}:"))
        self.state_view = QTextEdit()
        self.state_view.setReadOnly(True)
        self.state_view.setMaximumHeight(160)
        self.state_view.setFont(QFont("Consolas", 9))
        telemetry_layout.addWidget(self.state_view)
        
        splitter.addWidget(telemetry_panel)
        splitter.setSizes([700, 350])
        layout.addWidget(splitter)

    def _send_chat_message(self):
        text = self.input_field.text().strip()
        if not text:
            return
        self.input_field.clear()
        task_type = self.task_selector.currentText()
        
        self.chat_history.append(f"<b style='color:#89b4fa;'>User:</b> {text}")
        self.send_btn.setEnabled(False)
        self.chat_history.append("<i style='color:#6c7086;'>LumenMAX is reasoning through ternary state transitions...</i>")
        
        self.chat_worker = ChatWorker(self.model, text, max_tokens=10, task_type=task_type)
        self.chat_worker.step_ready.connect(self._update_telemetry)
        self.chat_worker.finished.connect(self._on_chat_finished)
        self.chat_worker.start()

    def _update_telemetry(self, step_info: dict):
        expert_names = ["0: Code Syntax", "1: Mathematics", "2: Logical Reasoning", "3: Structured Text"]
        exp_id = step_info['expert_id']
        self.expert_label.setText(f"Active Expert: {expert_names[exp_id]}")
        
        conf_names = ["0: NOT_READY (Iterating)", "1: PROBABLY_READY", "2: READY (Halted)"]
        self.confidence_label.setText(f"Halting Confidence: {conf_names[step_info['confidence']]}")
        
        self.cycles_label.setText(f"Reasoning Depth: {step_info['cycles']} internal cycle(s)")
        self.state_norm_label.setText(f"Active Ternary State Norm: {step_info['state_norm']} / {self.model.state_dim}")
        
        if step_info['loop_detected']:
            self.loop_label.setText("Repetition Loop Status: ⚠️ LOOP BROKEN")
            self.loop_label.setStyleSheet("color: #f38ba8; font-weight: bold;")
        else:
            self.loop_label.setText("Repetition Loop Status: Clean trajectory")
            self.loop_label.setStyleSheet("color: #a6e3a1;")
            
        gate = step_info.get('gate', np.zeros(self.model.state_dim))
        n_upd = int(np.sum(gate == 0))
        n_ret = int(np.sum(gate == 1))
        n_clr = int(np.sum(gate == -1))
        self.gate_label.setText(f"3-Way Gate: {n_upd} Update | {n_ret} Retain | {n_clr} Decay")
        
        # Display state vector
        s_str = " ".join([f"{v:+d}" for v in self.model.state])
        self.state_view.setText(f"State S_t (dim={self.model.state_dim}):\n[{s_str}]")

    def _on_chat_finished(self, response: str):
        # Remove thinking prompt and print actual generated text
        cursor = self.chat_history.textCursor()
        cursor.movePosition(cursor.MoveOperation.End)
        self.chat_history.append(f"<b style='color:#a6e3a1;'>LumenMAX:</b> <span style='color:#cdd6f4; font-family:Consolas;'>{response}</span>\n")
        self.send_btn.setEnabled(True)
        self.input_field.setFocus()

    def _reset_chat_state(self):
        self.model.reset_state()
        self.chat_history.append("<i style='color:#f9e2af;'>[System] LumenMAX internal short-term state cleared. Persistent memory preserved.</i>\n")
        self.state_view.clear()
        self.confidence_label.setText("Halting Confidence: Reset")

    # ------------------------------------------------------------
    # TAB 2: DISCRETE TRAINING & SYNAPTIC ECOLOGY
    # ------------------------------------------------------------
    def _setup_train_tab(self):
        layout = QVBoxLayout(self.train_tab)
        layout.setContentsMargins(10, 10, 10, 10)
        layout.setSpacing(10)
        
        # Controls Row
        ctrl_box = QGroupBox("Training Configuration & Execution")
        ctrl_layout = QHBoxLayout(ctrl_box)
        
        ctrl_layout.addWidget(QLabel("Epochs:"))
        self.epoch_spin = QSpinBox()
        self.epoch_spin.setRange(1, 50)
        self.epoch_spin.setValue(10)
        ctrl_layout.addWidget(self.epoch_spin)
        
        ctrl_layout.addWidget(QLabel("Dataset Mode:"))
        self.dataset_combo = QComboBox()
        self.dataset_combo.addItems([
            "60/20/20 Cognitive Suite (50 tasks)",
            "Code Syntax Only (30 tasks)",
            "Math & Arithmetic (10 tasks)",
            "Structured Text (10 tasks)"
        ])
        ctrl_layout.addWidget(self.dataset_combo)
        
        self.train_btn = QPushButton("🚀 Run Discrete Credit Training")
        self.train_btn.setFont(QFont("Segoe UI", 10, QFont.Weight.Bold))
        self.train_btn.setStyleSheet("background-color: #89b4fa; color: #11111b; padding: 6px 14px;")
        self.train_btn.clicked.connect(self._start_training)
        ctrl_layout.addWidget(self.train_btn)
        
        self.reinit_btn = QPushButton("Reset Synapses")
        self.reinit_btn.clicked.connect(self._reinit_model)
        ctrl_layout.addWidget(self.reinit_btn)
        
        layout.addWidget(ctrl_box)
        
        # Progress Bar & Status
        self.train_progress = QProgressBar()
        self.train_progress.setValue(0)
        self.train_progress.setTextVisible(True)
        layout.addWidget(self.train_progress)
        
        self.train_status_label = QLabel("Status: Ready to train ternary cognitive parameters.")
        self.train_status_label.setStyleSheet("color: #cdd6f4;")
        layout.addWidget(self.train_status_label)
        
        # Interactive Custom Pair Ingestion
        custom_box = QGroupBox("Add Custom Training Transition")
        custom_layout = QHBoxLayout(custom_box)
        
        self.custom_input = QLineEdit()
        self.custom_input.setPlaceholderText("Input token (e.g. 'while', '7', 'SPEC')...")
        
        self.custom_target = QLineEdit()
        self.custom_target.setPlaceholderText("Target token (e.g. 'x', '8', 'STATE')...")
        
        self.custom_cat = QComboBox()
        self.custom_cat.addItems(["code", "math", "structured"])
        
        self.add_custom_btn = QPushButton("Add & Train Step")
        self.add_custom_btn.clicked.connect(self._train_custom_step)
        
        custom_layout.addWidget(QLabel("Input:"))
        custom_layout.addWidget(self.custom_input)
        custom_layout.addWidget(QLabel("Target:"))
        custom_layout.addWidget(self.custom_target)
        custom_layout.addWidget(QLabel("Domain:"))
        custom_layout.addWidget(self.custom_cat)
        custom_layout.addWidget(self.add_custom_btn)
        layout.addWidget(custom_box)
        
        # Parameter Accountability & Group Inspection Tables
        splitter = QSplitter(Qt.Orientation.Horizontal)
        
        # Synapse Accountability Table
        syn_box = QGroupBox("🔬 Synaptic Parameter Agents (W_out Top Contributors)")
        syn_layout = QVBoxLayout(syn_box)
        self.synapse_table = QTableWidget(6, 6)
        self.synapse_table.setHorizontalHeaderLabels(["Matrix", "Synapse [r,c]", "Weight W", "Score", "Success", "Failures"])
        self.synapse_table.horizontalHeader().setSectionResizeMode(QHeaderView.ResizeMode.Stretch)
        syn_layout.addWidget(self.synapse_table)
        splitter.addWidget(syn_box)
        
        # Competitive Synapse Groups Table
        grp_box = QGroupBox("🏆 Competitive Populations (W_rec Synapse Groups)")
        grp_layout = QVBoxLayout(grp_box)
        self.group_table = QTableWidget(4, 5)
        self.group_table.setHorizontalHeaderLabels(["Group", "Score", "Successes", "Failures", "Status"])
        self.group_table.horizontalHeader().setSectionResizeMode(QHeaderView.ResizeMode.Stretch)
        grp_layout.addWidget(self.group_table)
        splitter.addWidget(grp_box)
        
        layout.addWidget(splitter)
        self._refresh_tables()

    def _start_training(self):
        epochs = self.epoch_spin.value()
        mode = self.dataset_combo.currentIndex()
        
        if mode == 0:
            active_dataset = self.dataset
        elif mode == 1:
            active_dataset = [d for d in self.dataset if d['category'] == 'code']
        elif mode == 2:
            active_dataset = [d for d in self.dataset if d['category'] == 'math']
        else:
            active_dataset = [d for d in self.dataset if d['category'] == 'structured']
            
        self.train_btn.setEnabled(False)
        self.train_status_label.setText(f"Status: Training on {len(active_dataset)} examples for {epochs} epochs...")
        self.train_progress.setValue(0)
        
        self.worker = TrainingWorker(self.model, active_dataset, epochs)
        self.worker.epoch_progress.connect(self._on_epoch_progress)
        self.worker.training_complete.connect(self._on_training_complete)
        self.worker.start()

    def _on_epoch_progress(self, ep: int, total_ep: int, acc: float, avg_cyc: float):
        pct = int(100.0 * ep / total_ep)
        self.train_progress.setValue(pct)
        self.train_status_label.setText(
            f"Training Epoch {ep}/{total_ep} — Task Accuracy: {acc*100:.1f}% — Reasoning Depth: {avg_cyc:.2f} cycles"
        )
        self._refresh_tables()

    def _on_training_complete(self, results: dict):
        self.train_btn.setEnabled(True)
        self.train_progress.setValue(100)
        self.train_status_label.setText(
            f"✅ Training Complete: {results['epochs']} epochs in {results['elapsed']:.2f}s — Final Accuracy: {results['final_acc']*100:.2f}%"
        )
        self._refresh_tables()
        QMessageBox.information(
            self, "Training Complete",
            f"LumenMAX discrete training complete!\n\n"
            f"Epochs: {results['epochs']}\n"
            f"Final Accuracy: {results['final_acc']*100:.2f}%\n"
            f"Time: {results['elapsed']:.2f}s\n\n"
            f"You can now switch to the Chat tab and inspect how response patterns changed!"
        )

    def _train_custom_step(self):
        inp = self.custom_input.text().strip()
        tgt = self.custom_target.text().strip()
        cat = self.custom_cat.currentText()
        if not inp or not tgt:
            QMessageBox.warning(self, "Missing Tokens", "Please provide both an input token and target token.")
            return
            
        res = self.model.train_example(inp, tgt, task_type=cat)
        self.custom_input.clear()
        self.custom_target.clear()
        
        status = "PASSED" if res['verified'] else f"MUTATED (Predicted '{res['predicted_token']}')"
        self.train_status_label.setText(f"Custom step trained: '{inp}' -> '{tgt}' | Outcome: {status} | Reward: {res['reward']}")
        self._refresh_tables()

    def _reinit_model(self):
        self.model = LumenMAX(state_dim=32, input_dim=32, vocab_size=64, seed=42)
        self._refresh_tables()
        self.train_status_label.setText("Model synapses re-initialized to balanced ternary baseline.")

    def _refresh_tables(self):
        # 1. Refresh Parameter Accountability Table
        top_synapses = inspect_parameter_accountability(self.model.ssm.W_out, top_k=6)
        for i, syn in enumerate(top_synapses):
            self.synapse_table.setItem(i, 0, QTableWidgetItem(syn['matrix']))
            self.synapse_table.setItem(i, 1, QTableWidgetItem(f"[{syn['row']}, {syn['col']}]"))
            self.synapse_table.setItem(i, 2, QTableWidgetItem(f"{syn['value']:+d}"))
            self.synapse_table.setItem(i, 3, QTableWidgetItem(f"{syn['score']:+d}"))
            self.synapse_table.setItem(i, 4, QTableWidgetItem(str(syn['successes'])))
            self.synapse_table.setItem(i, 5, QTableWidgetItem(str(syn['failures'])))
            
        # 2. Refresh Group Competition Table
        groups = inspect_group_competition(self.model.ssm.W_rec)
        for i, grp in enumerate(groups):
            self.group_table.setItem(i, 0, QTableWidgetItem(grp['name']))
            self.group_table.setItem(i, 1, QTableWidgetItem(f"{grp['score']:+d}"))
            self.group_table.setItem(i, 2, QTableWidgetItem(str(grp['successes'])))
            self.group_table.setItem(i, 3, QTableWidgetItem(str(grp['failures'])))
            status_item = QTableWidgetItem("SUPPRESSED" if grp['suppressed'] else "ACTIVE")
            if grp['suppressed']:
                status_item.setForeground(QColor("#f38ba8"))
            else:
                status_item.setForeground(QColor("#a6e3a1"))
            self.group_table.setItem(i, 4, status_item)

    # ------------------------------------------------------------
    # MODERN DARK THEME STYLING
    # ------------------------------------------------------------
    def _apply_dark_theme(self):
        style = """
        QMainWindow {
            background-color: #1e1e2e;
        }
        QWidget {
            color: #cdd6f4;
            background-color: #1e1e2e;
            font-family: 'Segoe UI', Arial, sans-serif;
        }
        #HeaderFrame {
            background-color: #181825;
            border: 1px solid #313244;
            border-radius: 6px;
        }
        QTabWidget::pane {
            border: 1px solid #313244;
            background-color: #1e1e2e;
            border-radius: 6px;
        }
        QTabBar::tab {
            background-color: #181825;
            color: #a6adc8;
            padding: 8px 18px;
            margin-right: 4px;
            border-top-left-radius: 6px;
            border-top-right-radius: 6px;
        }
        QTabBar::tab:selected {
            background-color: #313244;
            color: #89b4fa;
        }
        QGroupBox {
            border: 1px solid #313244;
            border-radius: 6px;
            margin-top: 12px;
            padding-top: 10px;
            font-weight: bold;
            color: #89b4fa;
        }
        QGroupBox::title {
            subcontrol-origin: margin;
            left: 10px;
            padding: 0 4px;
        }
        QTextEdit, QLineEdit, QComboBox, QSpinBox {
            background-color: #11111b;
            border: 1px solid #313244;
            border-radius: 4px;
            padding: 6px;
            color: #cdd6f4;
        }
        QPushButton {
            background-color: #313244;
            color: #cdd6f4;
            border: 1px solid #45475a;
            border-radius: 4px;
            padding: 6px 12px;
        }
        QPushButton:hover {
            background-color: #45475a;
            color: #89b4fa;
        }
        QPushButton:pressed {
            background-color: #585b70;
        }
        QProgressBar {
            background-color: #11111b;
            border: 1px solid #313244;
            border-radius: 4px;
            text-align: center;
            color: #cdd6f4;
        }
        QProgressBar::chunk {
            background-color: #a6e3a1;
            border-radius: 3px;
        }
        QTableWidget {
            background-color: #11111b;
            border: 1px solid #313244;
            gridline-color: #313244;
            color: #cdd6f4;
        }
        QHeaderView::section {
            background-color: #181825;
            color: #89b4fa;
            border: 1px solid #313244;
            padding: 4px;
        }
        """
        self.setStyleSheet(style)


# ============================================================
# ENTRY POINT
# ============================================================

def main():
    app = QApplication(sys.argv)
    window = LumenMAXGUI()
    window.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
