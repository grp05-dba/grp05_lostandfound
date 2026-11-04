(() => {
  const API = window.location.origin + "/api/public";
  const ADMIN_API =
    window.location.protocol +
    "//" +
    window.location.hostname +
    ":8001/api/admin";
  const LOCATIONS = [
    "Library",
    "Computer Laboratory",
    "Covered Court",
    "Canteen",
    "Room 101",
    "Room 102",
    "Room 103",
    "Room 104",
    "Room 201",
    "Room 202",
    "Room 203",
    "Room 204",
    "Room 301",
    "Room 302",
    "Room 303",
    "Room 304",
    "AVR 101",
    "AVR 102",
    "AVR 201",
    "AVR 202",
    "Main Gate / Guardhouse",
    "Student Lounge (Main Gate)",
    "Student Lounge (Admin)",
    "Student Lounge (Eco Park)",
    "Eco-Park",
    "Eco-Park Washroom",
    "1st Floor Washroom",
    "2nd Floor Washroom",
  ];
  const $ = (s, root = document) => root.querySelector(s);
  const state = { items: [], categories: [] };
  const toast = (message) => {
    const el = $("#toast");
    el.textContent = message;
    el.classList.add("show");
    setTimeout(() => el.classList.remove("show"), 3200);
  };
  async function request(url, options = {}) {
    const res = await fetch(url, options);
    const data = await res.json().catch(() => ({}));
    if (!res.ok)
      throw new Error(
        data.message || data.error || "The request could not be completed.",
      );
    return data;
  }
  function message(form, text, error = false) {
    const el = $(".form-message", form);
    el.textContent = text;
    el.classList.toggle("error", error);
  }
  function esc(value) {
    return String(value ?? "").replace(
      /[&<>"']/g,
      (c) =>
        ({
          "&": "&amp;",
          "<": "&lt;",
          ">": "&gt;",
          '"': "&quot;",
          "'": "&#39;",
        })[c],
    );
  }
  function fillSelects() {
    const opts = state.categories
      .map(
        (c) =>
          '<option value="' +
          esc(c.category_id) +
          '">' +
          esc(c.name) +
          "</option>",
      )
      .join("");
    $(".category-options").innerHTML =
      '<option value="">Choose category</option>' + opts;
    $("#category-filter").innerHTML =
      '<option value="">All categories</option>' + opts;
    document
      .querySelectorAll(".location-options")
      .forEach(
        (s) =>
          (s.innerHTML =
            '<option value="">Choose campus location (optional)</option>' +
            LOCATIONS.map((x) => "<option>" + esc(x) + "</option>").join("")),
      );
  }
  function imageUrl(item) {
    const img = Array.isArray(item.images) && item.images[0];
    if (!img) return "";
    const url = img.url || "";
    return url.startsWith("http") ? url : window.location.origin + url;
  }
  function render() {
    const q = $("#search-input").value.trim().toLowerCase(),
      cat = $("#category-filter").value,
      date = $("#date-filter").value;
    const rows = state.items.filter(
      (i) =>
        (!q ||
          [i.title, i.description, i.location_found].some((v) =>
            String(v || "")
              .toLowerCase()
              .includes(q),
          )) &&
        (!cat || String(i.category_id) === cat) &&
        (!date || String(i.date_found || "").slice(0, 10) === date),
    );
    $("#result-count").textContent = rows.length;
    const grid = $("#item-grid");
    grid.replaceChildren();
    if (!rows.length) {
      grid.innerHTML =
        '<div class="empty-state">No items match those filters. Try a different search or reset your filters.</div>';
      return;
    }
    rows.forEach((item) => {
      const card = document.createElement("article");
      card.className = "item-card";
      card.tabIndex = 0;
      card.setAttribute("role", "button");
      card.setAttribute("aria-label", "View details for " + (item.title || "found item"));
      const img = imageUrl(item);
      card.innerHTML =
        '<div class="item-image">' +
        (img
          ? '<img loading="lazy" src="' +
            esc(img) +
            '" alt="' +
            esc(item.title || "Found item") +
            '">'
          : '<span class="image-placeholder">◇</span>') +
        '<span class="status-pill">Unclaimed</span></div><div class="item-body"><span class="item-category">' +
        esc(
          item.category_name ||
            state.categories.find(
              (c) => String(c.category_id) === String(item.category_id),
            )?.name ||
            "Found property",
        ) +
        "</span><h3>" +
        esc(item.title || "Untitled item") +
        '</h3><p class="item-description">' +
        esc(item.description || "No description provided.") +
        '</p><div class="item-meta"><span>⌖ ' +
        esc(item.location_found || "Campus") +
        "</span><span>◷ " +
        esc(item.date_found || "Date unavailable") +
        '</span></div><button class="button button-primary claim-button" type="button">Claim this item <span>↗</span></button></div>';
      $(".claim-button", card).addEventListener("click", (event) => { event.stopPropagation(); openClaim(item); });
      card.addEventListener("click", () => openItemDetails(item));
      card.addEventListener("keydown", (event) => {
        if (event.target === card && (event.key === "Enter" || event.key === " ")) {
          event.preventDefault();
          openItemDetails(item);
        }
      });
      grid.append(card);
    });
  }
  async function loadCatalog() {
    const status = $("#catalog-status");
    status.textContent = "Loading found items…";
    try {
      const [items, cats] = await Promise.all([
        request(API + "/items"),
        request(API + "/categories"),
      ]);
      state.items = Array.isArray(items) ? items : [];
      state.categories = Array.isArray(cats) ? cats : [];
      fillSelects();
      render();
      status.textContent =
        "Showing currently unclaimed items from the campus catalog.";
    } catch (e) {
      status.textContent = "The catalog could not be loaded. " + e.message;
      $("#item-grid").innerHTML =
        '<div class="empty-state">We could not connect to the catalog. Please refresh or try again shortly.</div>';
    }
  }
  function openDialog(id) {
    const d = document.getElementById(id);
    if (d && !d.open) d.showModal();
  }
  function openItemDetails(item) {
    const gallery = Array.isArray(item.images) ? item.images : [];
    const images = gallery.length
      ? '<div class="public-item-gallery">' + gallery.map((entry) => {
          const url = entry.url || "";
          const src = url.startsWith("http") ? url : window.location.origin + url;
          return '<button type="button" class="public-image-preview-trigger" data-preview-image="' + esc(src) + '" aria-label="View photo larger"><img src="' + esc(src) + '" alt="' + esc(item.title || "Found item") + ' photo"></button>';
        }).join("") + "</div>"
      : '<div class="public-item-no-image">No photo available</div>';
    const category = item.category_name || state.categories.find((c) => String(c.category_id) === String(item.category_id))?.name || "Found property";
    $("#item-detail-content").innerHTML = images +
      '<div class="public-item-detail"><span class="item-category">' + esc(category) + '</span><h3>' + esc(item.title || "Found item") + '</h3>' +
      '<p>' + esc(item.description || "No description provided.") + '</p><dl>' +
      '<dt>Location found</dt><dd>' + esc(item.location_found || "Not specified") + '</dd>' +
      '<dt>Date found</dt><dd>' + esc(item.date_found || "Not available") + '</dd>' +
      '<dt>Time found</dt><dd>' + esc(item.time_found || "Not available") + '</dd>' +
      '<dt>Status</dt><dd><span class="status-pill">Unclaimed</span></dd></dl>' +
      '<button type="button" class="button button-primary" id="detail-claim-button">Claim this item <span>↗</span></button></div>';
    $("#item-detail-title").textContent = item.title || "Found item details";
    $("#detail-claim-button").addEventListener("click", () => {
      closeDialogs();
      openClaim(item);
    });
    openDialog("item-detail-dialog");
  }
  function closeDialogs() {
    document.querySelectorAll("dialog[open]").forEach((d) => d.close());
  }
  function validFiles(input) {
    const f = Array.from(input.files || []);
    if (!f.length) return "Please attach at least one image.";
    if (f.length > 5) return "You can attach up to five images.";
    if (
      f.some((x) => !["image/jpeg", "image/png", "image/webp"].includes(x.type))
    )
      return "Use JPG, PNG or WebP images only.";
    if (f.some((x) => x.size < 1 || x.size > 5 * 1024 * 1024))
      return "Each image must be 5 MB or smaller.";
    return "";
  }
  document.querySelectorAll("input[type=file]").forEach((input) =>
    input.addEventListener("change", () => {
      const box = input.parentElement.querySelector(".file-list");
      const error = validFiles(input);
      box.textContent =
        error ||
        Array.from(input.files)
          .map((f) => f.name)
          .join(" · ");
      box.style.color = error ? "#b42c3f" : "";
    }),
  );
  function validateContact(data) {
    const email = String(data.get("email") || "").trim(),
      phone = String(data.get("phone_number") || "").trim(),
      pref = data.get("contact_preference");
    if (!email && !phone) return "Provide an email address or phone number.";
    if (pref === "email" && !email)
      return "Add an email address or choose SMS.";
    if (pref === "sms" && !phone) return "Add a phone number or choose email.";
    return "";
  }
  function submitState(form, busy) {
    const b = $("button[type=submit]", form);
    b.disabled = busy;
    b.dataset.label ??= b.textContent;
    b.textContent = busy ? "Submitting…" : b.dataset.label;
  }
  $("#lost-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const form = e.currentTarget,
      data = new FormData(form),
      files = form.elements["images[]"];
    const fileError = validFiles(files),
      contactError = validateContact(data);
    if (fileError || contactError) {
      message(form, fileError || contactError, true);
      return;
    }
    submitState(form, true);
    message(form, "Sending your lost report…");
    try {
      const result = await request(API + "/lost-reports/add", {
        method: "POST",
        body: data,
      });
      message(
        form,
        (result.message || "Your report was submitted.") +
          " Keep an eye on the contact method you provided. Please save any reference code shown by the office.",
        false,
      );
      toast("Lost report submitted");
      form.reset();
      $(".file-list", form).textContent =
        "Choose clear photos that can help identify your item.";
    } catch (err) {
      message(form, err.message, true);
    } finally {
      submitState(form, false);
    }
  });
  function openClaim(item) {
    const form = $("#claim-form");
    form.reset();
    form.elements.item_id.value = item.item_id;
    $("#claim-item-summary").textContent =
      "You are requesting: " +
      (item.title || "Found item") +
      ". Bring your physical Student ID during pickup.";
    $(".file-list", form).textContent =
      "Upload your Student ID or clear proof of ownership.";
    message(form, "");
    openDialog("claim-dialog");
  }
  $("#claim-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const form = e.currentTarget,
      data = new FormData(form),
      fileError = validFiles(form.elements["images[]"]),
      contactError = validateContact(data);
    if (fileError || contactError) {
      message(form, fileError || contactError, true);
      return;
    }
    submitState(form, true);
    message(form, "Submitting your claim request…");
    try {
      const result = await request(API + "/claims/add", {
        method: "POST",
        body: data,
      });
      message(
        form,
        (result.message || "Claim request submitted.") +
          " Bring your physical Student ID to the Lost & Found office. The office will verify your claim in person.",
      );
      toast("Claim request submitted");
      form.reset();
      $(".file-list", form).textContent =
        "Upload your Student ID or clear proof of ownership.";
    } catch (err) {
      message(form, err.message, true);
    } finally {
      submitState(form, false);
    }
  });
  $("#track-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const form = e.currentTarget,
      code = form.elements.code.value.trim(),
      kind = form.elements.kind.value;
    message(form, "Looking up your private submission…");
    $("#track-result").hidden = true;
    try {
      const endpoint = kind === "lost" ? "/lost-reports/view" : "/claims/view",
        key = kind === "lost" ? "report_code" : "claim_code";
      const data = await request(API + endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ [key]: code }),
      });
      if (data.message && Object.keys(data).length === 1)
        throw new Error(data.message);
      const fields =
        kind === "lost"
          ? [
              "report_code",
              "title",
              "category_name",
              "location_lost",
              "date_lost",
              "status",
              "created_at",
            ]
          : [
              "claim_code",
              "title",
              "item_title",
              "full_name",
              "status",
              "created_at",
            ];
      const result = $("#track-result");
      let extra = "";
      if (kind === "lost") {
        try {
          const matches = await request(
            API + "/lost-reports/matches/" + encodeURIComponent(code),
          );
          extra =
            '<section class="match-results"><h4>Potential matches</h4>' +
            (Array.isArray(matches) && matches.length
              ? '<div class="match-grid">' +
                matches
                  .map((item) => {
                    const img = imageUrl(item);
                    return (
                      '<article class="match-card">' +
                      (img
                        ? '<img src="' +
                          esc(img) +
                          '" alt="' +
                          esc(item.title || "Potential match") +
                          '">'
                        : '<span class="match-placeholder">◇</span>') +
                      "<div><b>" +
                      esc(item.title || "Found item") +
                      "</b><small>" +
                      esc(item.location_found || "Campus") +
                      " · " +
                      esc(item.date_found || "Date unavailable") +
                      "</small><p>" +
                      esc(item.description || "") +
                      '</p><button type="button" class="button button-primary" data-match-claim="' +
                      esc(item.item_id) +
                      '">Request claim</button></div></article>'
                    );
                  })
                  .join("") +
                "</div>"
              : "<p>No potential matches have been identified yet. Check again later.</p>") +
            "</section>";
        } catch (matchError) {
          extra =
            '<section class="match-results"><h4>Potential matches</h4><p>Matches are generated automatically when suitable found items are available.</p></section>';
        }
      }
      const cancel =
        kind === "lost" && data.status === "active"
          ? '<div class="track-actions"><button type="button" class="button button-quiet" data-cancel-report="' +
            esc(code) +
            '">Cancel this report</button></div>'
          : "";
      result.innerHTML =
        "<h3>Submission details</h3><dl>" +
        fields
          .filter(
            (k) => data[k] !== undefined && data[k] !== null && data[k] !== "",
          )
          .map(
            (k) =>
              "<dt>" +
              esc(k.replaceAll("_", " ")) +
              "</dt><dd>" +
              esc(data[k]) +
              "</dd>",
          )
          .join("") +
        "</dl>" +
        (kind === "lost"
          ? extra
          : "<p>Bring your physical Student ID and reference code to the Lost & Found office for in-person verification.</p>") +
        cancel;
      result.hidden = false;
      message(form, "Submission found.");
    } catch (err) {
      message(form, err.message, true);
    }
  });
  $("#track-result").addEventListener("click", async (e) => {
    const cancel = e.target.closest("[data-cancel-report]");
    if (cancel) {
      if (!window.confirm("Cancel this active lost report?")) return;
      cancel.disabled = true;
      try {
        const result = await request(API + "/lost-reports/cancel", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ report_code: cancel.dataset.cancelReport }),
        });
        $("#track-result").innerHTML =
          "<h3>Report cancelled</h3><p>" +
          esc(result.message || "Your lost report has been cancelled.") +
          "</p>";
        toast("Lost report cancelled");
      } catch (error) {
        cancel.disabled = false;
        toast(error.message);
      }
    }
    const claim = e.target.closest("[data-match-claim]");
    if (claim) {
      const item = state.items.find(
        (x) => String(x.item_id) === String(claim.dataset.matchClaim),
      );
      if (item) openClaim(item);
      else {
        try {
          const matches = await request(API + "/items");
          const found = matches.find(
            (x) => String(x.item_id) === String(claim.dataset.matchClaim),
          );
          if (found) openClaim(found);
          else toast("This item is no longer available to claim.");
        } catch (error) {
          toast(error.message);
        }
      }
    }
  });
  document.querySelectorAll("[data-open]").forEach((b) =>
    b.addEventListener("click", () => {
      if (b.dataset.open === "track-dialog") {
        $("#track-result").hidden = true;
        message($("#track-form"), "");
      }
      openDialog(b.dataset.open);
    }),
  );
  document.addEventListener("click", (event) => {
    const imageTrigger = event.target.closest("[data-preview-image]");
    if (!imageTrigger) return;
    $("#public-image-preview").src = imageTrigger.dataset.previewImage;
    openDialog("public-image-preview-dialog");
  });
  document
    .querySelectorAll("[data-close]")
    .forEach((b) => b.addEventListener("click", closeDialogs));
  document.querySelectorAll("dialog").forEach((d) =>
    d.addEventListener("click", (e) => {
      if (e.target === d) d.close();
    }),
  );
  $("#search-input").addEventListener("input", render);
  $("#category-filter").addEventListener("change", render);
  $("#date-filter").addEventListener("change", render);
  $("#reset-filters").addEventListener("click", () => {
    $("#search-input").value = "";
    $("#category-filter").value = "";
    $("#date-filter").value = "";
    render();
  });
  $(".mobile-menu").addEventListener("click", () => {
    const nav = $(".main-nav");
    nav.style.display = nav.style.display === "flex" ? "none" : "flex";
    nav.style.position = "absolute";
    nav.style.top = "70px";
    nav.style.left = "0";
    nav.style.right = "0";
    nav.style.padding = "16px 22px";
    nav.style.background = "#fff";
    nav.style.boxShadow = "0 12px 25px #16223b14";
  });
  loadCatalog();
})();
