function getParam(paramName) {
  return new URLSearchParams(location.search).get(paramName);
}

$(function () {
  const uid = getParam('uid');
  $.get('/consoles/' + encodeURIComponent(uid), function (data) {
    if (data.length) {
      const r = data[0];
      let notes = r.Notes;
      if (notes === null) notes = "";
      let cond = r.SealOrCIB;
      if (cond === "Neither") cond = "";

      let html = `
        <tr><th>UID</th><td>${r["UID"] || ''}</td></tr>
        <tr><th>Model Name</th><td>${r["ModelName"] || ''}</td></tr>
        <tr><th>Region</th><td>${r["Region"] || ''}</td></tr>
        <tr><th>Peripheral</th><td>${r["PeripheralName"] || ''}</td></tr>
        <tr><th>Condition</th><td>${r.Condition + " " + cond}</td></tr>
        <tr><th>Notes</th><td>${notes}</td></tr>
      `;
      $('#viewTable tbody').html(html);
    }
  });
});