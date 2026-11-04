(() => {
  const ADMIN = window.location.origin + "/api/admin",
    PUBLIC =
      window.location.protocol +
      "//" +
      window.location.hostname +
      ":8000/api/public";
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
  const $ = (s, r = document) => r.querySelector(s),
    state = { items: [], reports: [], claims: [], categories: [] };
  const toast = (t) => {
    const n = $("#toast");
    n.textContent = t;
    n.classList.add("show");
    setTimeout(() => n.classList.remove("show"), 3000);
  };
  async function request(url, options = {}) {
    const r = await fetch(url, options),
      d = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(d.message || d.error || "Request failed");
    return d;
  }
  function status(text) {
    $("#api-state").classList.toggle("connected", text === "Connected");
    $("#api-state").lastChild.textContent = text;
  }
  function msg(form, text, error = false) {
    const n = $(".form-message", form);
    n.textContent = text;
    n.classList.toggle("error", error);
  }
  function safe(v) {
    return String(v ?? "").replace(
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
  function date(v) {
    return v ? String(v).slice(0, 10) : "—";
  }
  function category(id) {
    return (
      state.categories.find((c) => String(c.category_id) === String(id))
        ?.name || "—"
    );
  }
  function image(item) {
    const u = item.images?.[0]?.url || "";
    return u
      ? u.startsWith("http")
        ? u
        : PUBLIC.replace("/api/public", "") + u
      : "";
  }
  function fillForm() {
    $("#item-category").innerHTML =
      '<option value="">Choose category</option>' +
      state.categories
        .map(
          (c) =>
            '<option value="' +
            safe(c.category_id) +
            '">' +
            safe(c.name) +
            "</option>",
        )
        .join("");
    $("#item-location").innerHTML =
      '<option value="">Choose campus location</option>' +
      LOCATIONS.map((x) => "<option>" + safe(x) + "</option>").join("");
  }
  function view(name) {
    document
      .querySelectorAll(".view")
      .forEach((v) => v.classList.toggle("active", v.id === "view-" + name));
    document
      .querySelectorAll(".nav-item")
      .forEach((b) => b.classList.toggle("active", b.dataset.view === name));
    const label = {
      overview: "Overview",
      inventory: "Found inventory",
      reports: "Lost reports",
      claims: "Claim verification",
    }[name];
    $("#page-label").textContent = label;
    $("#page-title").textContent =
      name === "overview" ? "Operations overview" : label;
  }
  function renderItems() {
    const q = $("#item-search").value.toLowerCase().trim(),
      s = $("#item-status-filter").value;
    const rows = state.items.filter(
      (i) =>
        (!q ||
          [i.title, i.description, i.location_found].some((v) =>
            String(v || "")
              .toLowerCase()
              .includes(q),
          )) &&
        (!s || i.status === s),
    );
    $("#items-table").innerHTML = rows.length
      ? rows
          .map(
            (i) =>
              '<tr><td><div class="table-primary"><span class="table-thumb">' +
              (image(i) ? '<img src="' + safe(image(i)) + '" alt="">' : "◇") +
              "</span><span><b>" +
              safe(i.title) +
              "</b><small>#" +
              safe(i.item_id) +
              "</small></span></div></td><td>" +
              safe(category(i.category_id)) +
              "</td><td>" +
              safe(i.location_found) +
              "</td><td>" +
              safe(date(i.date_found)) +
              '</td><td><span class="status ' +
              safe(i.status) +
              '">' +
              safe(i.status) +
              '</span></td><td><button class="row-action" data-detail="item" data-id="' +
              safe(i.item_id) +
              '">View details</button></td></tr>',
          )
          .join("")
      : '<tr><td colspan="6" class="empty-row">No inventory records match your search.</td></tr>';
    $("#nav-items-count").textContent = state.items.length;
  }
  function renderReports() {
    const q = $("#report-search").value.toLowerCase().trim(),
      s = $("#report-status-filter").value;
    const rows = state.reports.filter(
      (r) =>
        (!q ||
          [
            r.report_code,
            r.full_name,
            r.title,
            r.student_number,
            r.description,
          ].some((v) =>
            String(v || "")
              .toLowerCase()
              .includes(q),
          )) &&
        (!s || r.status === s),
    );
    $("#reports-table").innerHTML = rows.length
      ? rows
          .map(
            (r) =>
              '<tr><td><div class="table-primary"><span><b>' +
              safe(r.report_code || "Report #" + r.report_id) +
              "</b><small>" +
              safe(date(r.created_at)) +
              "</small></span></div></td><td>" +
              safe(r.full_name) +
              "<br><small>" +
              safe(r.student_number) +
              "</small></td><td>" +
              safe(r.title) +
              "</td><td>" +
              safe(r.location_lost || "Not specified") +
              '</td><td><span class="status ' +
              safe(r.status) +
              '">' +
              safe(r.status) +
              '</span></td><td><button class="row-action" data-detail="report" data-id="' +
              safe(r.report_id) +
              '">Review</button></td></tr>',
          )
          .join("")
      : '<tr><td colspan="6" class="empty-row">No lost reports match your search.</td></tr>';
    $("#nav-reports-count").textContent = state.reports.length;
  }
  function renderClaims() {
    const q = $("#claim-search").value.toLowerCase().trim(),
      s = $("#claim-status-filter").value;
    const rows = state.claims.filter(
      (c) =>
        (!q ||
          [
            c.claim_code,
            c.full_name,
            c.student_number,
            c.title,
            c.item_title,
          ].some((v) =>
            String(v || "")
              .toLowerCase()
              .includes(q),
          )) &&
        (!s || c.status === s),
    );
    $("#claims-table").innerHTML = rows.length
      ? rows
          .map(
            (c) =>
              "<tr><td><b>" +
              safe(c.claim_code || "Claim #" + c.claim_id) +
              "</b></td><td>" +
              safe(c.full_name) +
              "<br><small>" +
              safe(c.student_number) +
              "</small></td><td>" +
              safe(c.item_title || c.title || "Item #" + c.item_id) +
              "</td><td>" +
              safe(date(c.created_at)) +
              '</td><td><span class="status ' +
              safe(c.status) +
              '">' +
              safe(c.status) +
              '</span></td><td><button class="row-action" data-detail="claim" data-id="' +
              safe(c.claim_id) +
              '">Verify</button></td></tr>',
          )
          .join("")
      : '<tr><td colspan="6" class="empty-row">No claim requests match your search.</td></tr>';
    $("#nav-claims-count").textContent = state.claims.length;
  }
  function renderOverview() {
    const active = state.reports.filter((x) => x.status === "active").length,
      pending = state.claims.filter((x) => x.status === "pending").length,
      released = state.claims.filter((x) => x.status === "approved").length;
    $("#metric-items").textContent = state.items.length;
    $("#metric-reports").textContent = active;
    $("#metric-claims").textContent = pending;
    $("#metric-released").textContent = released;
    $("#recent-items").innerHTML =
      state.items
        .slice(0, 5)
        .map(
          (i) =>
            '<div class="compact-row"><span class="mini-thumb">' +
            (image(i) ? '<img src="' + safe(image(i)) + '" alt="">' : "◇") +
            "</span><span><b>" +
            safe(i.title) +
            "</b><small>" +
            safe(i.location_found) +
            " · " +
            safe(date(i.date_found)) +
            '</small></span><span class="status ' +
            safe(i.status) +
            '">' +
            safe(i.status) +
            "</span></div>",
        )
        .join("") ||
      '<div class="loading">No found items have been recorded.</div>';
    const attention = [
      ...state.claims
        .filter((c) => c.status === "pending")
        .slice(0, 4)
        .map((c) => ({
          icon: "✓",
          title: "Claim awaiting verification",
          detail:
            (c.claim_code || "Claim #" + c.claim_id) +
            " · " +
            (c.full_name || "Student"),
        })),
      ...state.reports
        .filter((r) => r.status === "active")
        .slice(0, 3)
        .map((r) => ({
          icon: "⌕",
          title: "Active lost report",
          detail:
            (r.report_code || "Report #" + r.report_id) +
            " · " +
            (r.title || "Item"),
        })),
    ];
    $("#attention-list").innerHTML = attention.length
      ? attention
          .slice(0, 6)
          .map(
            (a) =>
              '<div class="attention-row"><span class="attention-icon">' +
              a.icon +
              "</span><span><b>" +
              safe(a.title) +
              "</b><small>" +
              safe(a.detail) +
              "</small></span></div>",
          )
          .join("")
      : '<div class="loading">No outstanding actions.</div>';
  }
  async function loadAll() {
    status("Connecting");
    $("#global-notice").textContent = "";
    try {
      const [items, reports, claims, cats] = await Promise.all([
        request(ADMIN + "/items"),
        request(ADMIN + "/lost-reports"),
        request(ADMIN + "/claims"),
        request(ADMIN + "/categories"),
      ]);
      state.items = Array.isArray(items) ? items : [];
      state.reports = Array.isArray(reports) ? reports : [];
      state.claims = Array.isArray(claims) ? claims : [];
      state.categories = Array.isArray(cats) ? cats : [];
      fillForm();
      renderItems();
      renderReports();
      renderClaims();
      renderOverview();
      status("Connected");
    } catch (e) {
      status("API unavailable");
      $("#global-notice").textContent =
        "Some records could not be loaded: " +
        e.message +
        " Check the Admin API and database connection.";
    }
  }
  function fileError(input) {
    const f = Array.from(input.files || []);
    if (!f.length) return "Attach at least one photo.";
    if (f.length > 5) return "Maximum of five photos.";
    if (
      f.some((x) => !["image/jpeg", "image/png", "image/webp"].includes(x.type))
    )
      return "Only JPG, PNG and WebP images are accepted.";
    if (f.some((x) => x.size < 1 || x.size > 5 * 1024 * 1024))
      return "Each image must be 5 MB or smaller.";
    return "";
  }
  $("#item-form").elements["images[]"].addEventListener("change", (e) => {
    $(".file-list").textContent =
      fileError(e.target) ||
      Array.from(e.target.files)
        .map((f) => f.name)
        .join(" · ");
  });
  $("#item-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const f = e.currentTarget,
      err = fileError(f.elements["images[]"]);
    if (err) {
      msg(f, err, true);
      return;
    }
    const btn = $("button[type=submit]", f);
    btn.disabled = true;
    msg(f, "Saving item and photos…");
    try {
      const data = await request(ADMIN + "/items/add", {
        method: "POST",
        body: new FormData(f),
      });
      msg(f, data.message || "Found item saved.");
      toast("Found item saved");
      f.reset();
      $("#item-dialog").close();
      await loadAll();
    } catch (error) {
      msg(f, error.message, true);
    } finally {
      btn.disabled = false;
    }
  });
  function editableField(name, value, kind) {
    const label = name.replaceAll("_", " ").replace(/\\b\\w/g, (c) => c.toUpperCase());
    const val = value ?? "";
    if (name === "status") {
      const options = kind === "claim"
        ? [["pending", "Pending"], ["approved", "Approved"], ["rejected", "Rejected"]]
        : [["active", "Active"], ["resolved", "Resolved"], ["cancelled", "Cancelled"]];
      return '<label class="field"><span>' + label + ' *</span><select name="status" required>' +
        options.map(([v, text]) => '<option value="' + v + '"' + (String(val) === v ? " selected" : "") + '>' + text + '</option>').join("") +
        '</select></label>';
    }
    if (name === "contact_preference") {
      return '<label class="field"><span>' + label + ' *</span><select name="' + name + '" required>' +
        ["email", "sms"].map((v) => '<option value="' + v + '"' + (String(val) === v ? " selected" : "") + '>' + v.toUpperCase() + '</option>').join("") +
        '</select></label>';
    }
    if (name === "category_id") {
      return '<label class="field"><span>Category *</span><select name="category_id" required>' +
        state.categories.map((c) => '<option value="' + safe(c.category_id) + '"' + (String(val) === String(c.category_id) ? " selected" : "") + '>' + safe(c.name) + '</option>').join("") +
        '</select></label>';
    }
    const types = { email: "email", phone_number: "tel", date_lost: "date", time_lost: "time", item_id: "number" };
    const type = types[name] || "text";
    const required = ["item_id", "full_name", "student_number", "category_id", "title", "description"].includes(name);
    const max = { full_name: 150, student_number: 50, email: 150, phone_number: 50, title: 255, location_lost: 255 }[name];
    const attrs = (max ? ' maxlength="' + max + '"' : "") + (name === "item_id" ? ' min="1"' : "");
    if (name === "description") {
      return '<label class="field field-wide"><span>' + label + (required ? ' *' : '') + '</span><textarea name="' + name + '" rows="3"' + (required ? ' required' : '') + '>' + safe(val) + '</textarea></label>';
    }
    return '<label class="field"><span>' + label + (required ? ' *' : '') + '</span><input name="' + name + '" type="' + type + '" value="' + safe(val) + '"' + attrs + (required ? ' required' : '') + '></label>';
  }

  async function detail(kind, id) {
    const rows = { item: state.items, report: state.reports, claim: state.claims }[kind] || [];
    const key = { item: "item_id", report: "report_id", claim: "claim_id" }[kind];
    const r = rows.find((x) => String(x[key]) === String(id));
    if (!r) return;

    if (kind === "item") {
      const fields = ["item_id", "title", "category_id", "description", "location_found", "date_found", "time_found", "status"];
      $("#detail-title").textContent = "Found item details";
      let html = '<div class="detail-grid">' + fields
        .filter((k) => r[k] !== undefined && r[k] !== null && r[k] !== "")
        .map((k) => "<b>" + safe(k.replaceAll("_", " ")) + "</b><span>" + safe(k === "category_id" ? category(r[k]) : r[k]) + "</span>")
        .join("") + "</div>";
      $("#detail-content").innerHTML = html;
      $("#detail-dialog").showModal();
      return;
    }

    const isClaim = kind === "claim";
    const fields = isClaim
      ? ["status", "item_id", "full_name", "student_number", "email", "phone_number", "contact_preference"]
      : ["status", "category_id", "title", "description", "location_lost", "date_lost", "time_lost", "full_name", "student_number", "email", "phone_number", "contact_preference"];
    const code = isClaim ? (r.claim_code || "Claim #" + r.claim_id) : (r.report_code || "Report #" + r.report_id);
    $("#detail-title").textContent = isClaim ? "Verify claim · " + code : "Review lost report · " + code;

    const imgs = Array.isArray(r.images) ? r.images : [];
    const imageHtml = imgs.length ? '<div class="detail-images">' + imgs.map((x) => {
      const u = x.url || "";
      const base = u.startsWith("/api/admin/") ? ADMIN.replace("/api/admin", "") : PUBLIC.replace("/api/public", "");
      return '<img src="' + safe(u.startsWith("http") ? u : base + u) + '" alt="Attached image">';
    }).join("") + "</div>" : "";

    $("#detail-content").innerHTML =
      imageHtml +
      '<form id="record-edit-form" class="form-grid" data-kind="' + kind + '" data-id="' + safe(id) + '">' +
      fields.map((name) => editableField(name, r[name], kind)).join("") +
      '<div class="form-message field-wide" role="status"></div>' +
      '<div class="form-actions field-wide"><button type="button" class="button button-light" data-close>Cancel</button>' +
      '<button class="button button-primary" type="submit">' + (isClaim ? "Save verification" : "Save review") + '</button></div></form>' +
      (!isClaim && r.report_code ? '<section class="admin-matches"><h3>Automatically identified potential matches</h3><div class="loading">Checking matching found items…</div></section>' : "");
    $("#detail-dialog").showModal();

    if (!isClaim && r.report_code) {
      const panel = $(".admin-matches", "#detail-content");
      try {
        const matches = await request(ADMIN + "/lost-reports/matches/" + encodeURIComponent(r.report_code));
        panel.innerHTML = "<h3>Automatically identified potential matches</h3>" +
          (Array.isArray(matches) && matches.length
            ? '<div class="admin-match-list">' + matches.map((m) =>
                "<article><b>" + safe(m.title || "Found item") + "</b><span>" +
                safe(m.location_found || "Campus") + " · " + safe(date(m.date_found)) +
                "</span><small>" + safe(m.description || "") + "</small></article>").join("") + "</div>"
            : "<p>No potential matches are currently recorded for this report.</p>");
      } catch (error) {
        panel.innerHTML = "<h3>Automatically identified potential matches</h3><p>Unable to load potential matches: " + safe(error.message) + "</p>";
      }
    }
  }

  async function submitRecordEdit(form) {
    const kind = form.dataset.kind;
    const id = form.dataset.id;
    const data = Object.fromEntries(new FormData(form).entries());
    if (kind === "claim") {
      data.item_id = Number(data.item_id);
      data.email = data.email.trim() || null;
      data.phone_number = data.phone_number.trim() || null;
    } else {
      data.category_id = Number(data.category_id);
      for (const field of ["location_lost", "date_lost", "time_lost", "email", "phone_number"]) {
        data[field] = data[field].trim() || null;
      }
    }
    const button = $('button[type="submit"]', form);
    button.disabled = true;
    msg(form, "Saving changes…");
    try {
      const endpoint = kind === "claim" ? ADMIN + "/claims/update" : ADMIN + "/lost-reports/update";
      await request(endpoint + "/" + id, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      $("#detail-dialog").close();
      toast("Record updated");
      await loadAll();
    } catch (error) {
      msg(form, error.message, true);
    } finally {
      button.disabled = false;
    }
  }

  function isClaimStatus(statusValue) {
    return ["pending", "approved", "rejected"].includes(statusValue);
  }
  async function patch(endpoint, id, data) {
    await request(endpoint + "/" + id, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    $("#detail-dialog").close();
    toast("Record updated");
    await loadAll();
  }
  document.addEventListener("submit", (e) => {\n    const form = e.target.closest("#record-edit-form");\n    if (form) {\n      e.preventDefault();\n      submitRecordEdit(form);\n    }\n  });\n  document.addEventListener("click", (e) => {
    const nav = e.target.closest("[data-view]");
    if (nav) view(nav.dataset.view);
    const go = e.target.closest("[data-view-go]");
    if (go) view(go.dataset.viewGo);
    const d = e.target.closest("[data-detail]");
    if (d) detail(d.dataset.detail, d.dataset.id);
    const si = e.target.closest("[data-status-item]");
    if (si)
      patch(ADMIN + "/items/update", si.dataset.id, {
        status: si.dataset.statusItem,
      }).catch((x) => toast(x.message));
    const sr = e.target.closest("[data-status-report]");
    if (sr)
      patch(ADMIN + "/lost-reports/update", sr.dataset.id, {
        status: sr.dataset.statusReport,
      }).catch((x) => toast(x.message));
    const sc = e.target.closest("[data-status-claim]");
    if (sc)
      patch(ADMIN + "/claims/update", sc.dataset.id, {
        status: sc.dataset.statusClaim,
      }).catch((x) => toast(x.message));
  });
  document
    .querySelectorAll("[data-close]")
    .forEach((b) =>
      b.addEventListener("click", () => b.closest("dialog").close()),
    );
  document.querySelectorAll("dialog").forEach((d) =>
    d.addEventListener("click", (e) => {
      if (e.target === d) d.close();
    }),
  );
  $("#open-item-form").addEventListener("click", () => {
    $("#item-form").reset();
    msg($("#item-form"), "");
    $("#item-dialog").showModal();
  });
  $("#refresh-all").addEventListener("click", loadAll);
  $("#item-search").addEventListener("input", renderItems);
  $("#item-status-filter").addEventListener("change", renderItems);
  $("#report-search").addEventListener("input", renderReports);
  $("#report-status-filter").addEventListener("change", renderReports);
  $("#claim-search").addEventListener("input", renderClaims);
  $("#claim-status-filter").addEventListener("change", renderClaims);
  loadAll();
})();
