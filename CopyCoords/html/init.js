window.addEventListener('message', function(e){
  let node = document.createElement('textarea');
  let sel = document.getSelection();
  
  node.textContent = e.data.coords;
  document.body.appendChild(node);

  sel.removeAllRanges();
  node.select();
  document.execCommand('copy');

  sel.removeAllRanges();
  document.body.removeChild(node);
});