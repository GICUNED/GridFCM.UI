let tab = document.querySelectorAll('nav-link');
let iterable = new Map(tab.entries());

for (let [i, cv] of iterable) {

      cv.addEventListener('click', function focus() {
        reset();
        cv.classList.add('active');
        console.log(clcik);
      });

      tab[0].click();

}
    
function reset() {
      iterable.forEach(el => el.classList.remove('active'));
}