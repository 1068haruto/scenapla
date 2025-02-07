import { Controller } from "@hotwired/stimulus";

// Stimulusコントローラーを定義
export default class extends Controller {
  static targets = ["textarea", "button"];

  connect() {
    // Turboによる遷移後に動作することを保証
    console.log("MemoController connected!");

    this.buttonTarget.addEventListener("click", () => this.toggleEdit());
  }

  toggleEdit() {
    const button = this.buttonTarget;
    const textarea = this.textareaTarget;

    if (button.dataset.action === "save") {
      this.saveMemo(textarea, button);
    } else {
      this.enableEditing(textarea, button);
    }
  }

  enableEditing(textarea, button) {
    button.dataset.action = "save";
    button.textContent = "保存";
    textarea.removeAttribute("readonly");
    button.classList.replace("btn-outline-secondary", "btn-outline-primary");
  }

  saveMemo(textarea, button) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    const ageGroup = textarea.dataset.ageGroup;
    const memoId = textarea.dataset.id; // 既存メモID

    const url = memoId ? `/memos/${memoId}` : "/memos"; // PATCHかPOSTのURLを決定
    const method = memoId ? "PATCH" : "POST"; // HTTPメソッドを切り替え

    fetch(url, {
      method: method,
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({
        memo: {
          content: textarea.value,
          age_group: parseInt(ageGroup)
        }
      })
    })
      .then(response => response.json())
      .then(data => {
        if (data.memo) {
          textarea.dataset.id = data.memo.id;
          button.dataset.action = "edit";
          button.textContent = "編集";
          textarea.setAttribute("readonly", true);
          button.classList.replace("btn-outline-primary", "btn-outline-secondary");
        } else {
          alert(data.message || "保存に失敗しました。");
        }
      });
  }
}