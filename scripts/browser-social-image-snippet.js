/*
Paste this into the browser DevTools Console while you are viewing a Facebook or Instagram post.
It finds the largest rendered image that looks like post media and prints Markdown-ready fields.
This works better than curl for Instagram because the browser has already rendered the page.
*/
(() => {
  const blocked = [
    'static.cdninstagram.com/rsrc',
    'static.xx.fbcdn.net',
    '/rsrc.php/',
    'emoji',
    'favicon',
    'profile_pic',
    's150x150'
  ];

  const imgs = [...document.images]
    .map((img) => {
      const rect = img.getBoundingClientRect();
      const src = img.currentSrc || img.src || '';
      const score = Math.round(
        Math.max(img.naturalWidth || 0, rect.width || 0) *
        Math.max(img.naturalHeight || 0, rect.height || 0)
      );
      return {
        src,
        alt: img.alt || '',
        naturalWidth: img.naturalWidth || 0,
        naturalHeight: img.naturalHeight || 0,
        renderedWidth: Math.round(rect.width || 0),
        renderedHeight: Math.round(rect.height || 0),
        score
      };
    })
    .filter((item) => item.src.startsWith('http'))
    .filter((item) => !blocked.some((bad) => item.src.includes(bad)))
    .filter((item) => item.score > 40000)
    .sort((a, b) => b.score - a.score);

  if (!imgs.length) {
    console.warn('No likely post images found. Try opening the post image/theater view first, then rerun this snippet.');
    return;
  }

  const best = imgs[0];
  const cleanPageUrl = location.href.split('?')[0];
  console.log('Best image candidate:');
  console.log(best);
  console.log('\nMarkdown fields:');
  console.log(`external_url: "${cleanPageUrl}"`);
  console.log(`image: "${best.src}"`);
  console.log('image_fit: "contain"');
  console.log('\nAll image candidates:');
  console.table(imgs.slice(0, 10));

  if (navigator.clipboard) {
    navigator.clipboard.writeText(`external_url: "${cleanPageUrl}"\nimage: "${best.src}"\nimage_fit: "contain"`).catch(() => {});
  }
})();
