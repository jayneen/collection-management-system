function getParam(paramName) {
  return new URLSearchParams(location.search).get(paramName);
}

$(function () {
  const uid = getParam('uid');
  $.get('/games/' + encodeURIComponent(uid), function (data) {
    if (data.length) {
      const r = data[0];
      let notes = r.Notes;
      if (notes === null) notes = "";
      let cond = r.SealOrCIB;
      if (cond === "Neither") cond = "";

      let html = `
        <tr><th>UID</th><td>${r["UID"] || ''}</td></tr>
        <tr><th>Game Name</th><td>${r["GameName"] || ''}</td></tr>
        <tr><th>Rating</th><td>${r["Rating"] || ''}</td></tr>
        <tr><th>Region</th><td>${r["Region"] || ''}</td></tr>
        <tr><th>Console Model</th><td>${r["ModelName"] || ''}</td></tr>
        <tr><th>Series</th><td>${r["Series"] || ''}</td></tr>
        <tr><th>Peripheral</th><td>${r["PeripheralName"] || ''}</td></tr>
        <tr><th>Genres</th><td>${r["Genres"] || ''}</td></tr>
        <tr><th>Condition</th><td>${r.Condition + " " + cond}</td></tr>
        <tr><th>Notes</th><td>${notes}</td></tr>
      `;
      $('#viewTable tbody').html(html);
    }
  });
});