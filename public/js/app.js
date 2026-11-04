const API = { public: 'api/public', admin: 'api/admin' };
const MAX_PHOTOS = 5;
const MAX_SIZE = 5 * 1024 * 1024;
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp'];

const byId = (id) => document.getElementById(id);
const statusNode = byId('form-status');

function showStatus(message, isError = false) {
  statusNode.textContent = message;
  statusNode.classList.toggle('error', isError);
}

async function requestJson(url, options = {}) {
  const response = await fetch(url, options);
  const payload = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(payload.message || payload.error || 'The request could not be completed.');
  return payload;
}

async function loadCategories() {
  const categories = await requestJson(API.public + '/categories');
  document.querySelectorAll('.category-select').forEach((select) => {
    select.replaceChildren(new Option('Select a category', ''));
    categories.forEach((category) => select.add(new Option(category.name, category.category_id)));
  });
}

function validatePhotos(files) {
  if (!files || files.length < 1) return 'Please select at least one item photo.';
  if (files.length > MAX_PHOTOS) return 'You can upload a maximum of five photos.';
  for (const file of files) {
    if (!ALLOWED_TYPES.includes(file.type)) return 'Photos must be JPEG, PNG, or WebP files.';
    if (file.size < 1 || file.size > MAX_SIZE) return 'Each photo must be no larger than 5 MB.';
  }
  return '';
}

function bindPhotoPreview(formId, previewId) {
  const form = byId(formId);
  const input = form.elements.photos;
  input.addEventListener('change', () => {
    const preview = byId(previewId);
    preview.replaceChildren();
    const error = validatePhotos(input.files);
    if (error && input.files.length) {
      const note = document.createElement('span');
      note.className = 'photo-chip';
      note.textContent = error;
      preview.append(note);
      return;
    }
    Array.from(input.files).forEach((file) => {
      const chip = document.createElement('span');
      chip.className = 'photo-chip';
      chip.textContent = file.name;
      preview.append(chip);
    });
  });
}

async function uploadPhotos(url, files) {
  const data = new FormData();
  Array.from(files).forEach((file) => data.append('photos[]', file));
  return requestJson(url, { method: 'POST', body: data });
}

function formObject(form) {
  return Object.fromEntries(new FormData(form).entries());
}

async function submitReport(form, kind) {
  const files = form.elements.photos.files;
  const photoError = validatePhotos(files);
  if (photoError) {
    showStatus(photoError, true);
    return;
  }

  const button = form.querySelector('.submit-button');
  button.disabled = true;
  button.textContent = 'Submitting report…';
  showStatus('');

  try {
    const values = formObject(form);
    delete values.photos;
    const isLost = kind === 'lost';
    const endpoint = isLost ? API.public + '/lost-reports/add' : API.admin + '/items/add';
    const created = await requestJson(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(values)
    });

    const recordId = isLost ? created.report_id : created.item_id;
    if (!recordId) throw new Error('The report was created, but the API did not return its record ID. Contact the project administrator before submitting again.');

    const photoEndpoint = isLost
      ? API.public + '/lost-reports/' + encodeURIComponent(recordId) + '/photos'
      : API.admin + '/items/' + encodeURIComponent(recordId) + '/photos';
    await uploadPhotos(photoEndpoint, files);

    const confirmation = isLost
      ? 'Lost item report submitted successfully. Reference: ' + (created.report_code || recordId)
      : 'Found item submitted successfully. Record ID: ' + recordId;
    showStatus(confirmation);
    form.reset();
    form.querySelector('.photo-preview').replaceChildren();
    if (!isLost) loadFoundItems();
  } catch (error) {
    showStatus(error.message, true);
  } finally {
    button.disabled = false;
    button.innerHTML = kind === 'lost'
      ? 'Submit lost item report <span>→</span>'
      : 'Submit found item <span>→</span>';
  }
}

function renderItems(items) {
  const container = byId('item-list');
  container.replaceChildren();
  if (!Array.isArray(items) || items.length === 0) {
    const empty = document.createElement('p');
    empty.className = 'empty-state';
    empty.textContent = 'No found items have been reported yet.';
    container.append(empty);
    return;
  }
  items.slice(0, 9).forEach((item) => {
    const card = document.createElement('article');
    card.className = 'item-card';
    const title = document.createElement('h3');
    title.textContent = item.title || 'Untitled item';
    const description = document.createElement('p');
    description.textContent = item.description || 'No description provided.';
    const meta = document.createElement('span');
    meta.className = 'item-meta';
    meta.textContent = item.location_found || 'Location not specified';
    card.append(title, description, meta);
    container.append(card);
  });
}

async function loadFoundItems() {
  const container = byId('item-list');
  try {
    const items = await requestJson(API.admin + '/items');
    renderItems(items);
  } catch (error) {
    container.replaceChildren();
    const message = document.createElement('p');
    message.className = 'empty-state';
    message.textContent = 'Found items are temporarily unavailable. ' + error.message;
    container.append(message);
  }
}

function setupTabs() {
  const tabs = [
    { button: byId('lost-tab'), panel: byId('lost-form') },
    { button: byId('found-tab'), panel: byId('found-form') }
  ];
  tabs.forEach(({ button, panel }) => button.addEventListener('click', () => {
    tabs.forEach((tab) => {
      const active = tab.button === button;
      tab.button.classList.toggle('active', active);
      tab.button.setAttribute('aria-selected', String(active));
      tab.panel.classList.toggle('hidden', !active);
    });
    showStatus('');
  }));
}

byId('lost-form').addEventListener('submit', (event) => {
  event.preventDefault();
  submitReport(event.currentTarget, 'lost');
});
byId('found-form').addEventListener('submit', (event) => {
  event.preventDefault();
  submitReport(event.currentTarget, 'found');
});
byId('refresh-items').addEventListener('click', loadFoundItems);

setupTabs();
bindPhotoPreview('lost-form', 'lost-preview');
bindPhotoPreview('found-form', 'found-preview');
loadCategories().catch((error) => {
  document.querySelectorAll('.category-select').forEach((select) => {
    select.replaceChildren(new Option('Categories unavailable', ''));
  });
  showStatus('Could not load categories: ' + error.message, true);
});
loadFoundItems();
