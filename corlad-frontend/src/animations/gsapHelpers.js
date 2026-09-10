import gsap from 'gsap';

export const animarPresionado = (elemento) => {
  if (!elemento) return;
  gsap.fromTo(
    elemento,
    { scale: 0.96 },
    { scale: 1, duration: 0.3, ease: 'back.out(2)' }
  );
};

export const animarShakeError = (elemento) => {
  if (!elemento) return;
  gsap.fromTo(
    elemento,
    { x: -10 },
    {
      x: 10,
      duration: 0.08,
      repeat: 5,
      yoyo: true,
      ease: 'power1.inOut',
      onComplete: () => {
        gsap.to(elemento, { x: 0, duration: 0.1 });
      },
    }
  );
};

export const animarEntradaEscalonada = (elementos, delay = 0.05) => {
  if (!elementos || elementos.length === 0) return;
  gsap.fromTo(
    elementos,
    { opacity: 0, y: 20 },
    {
      opacity: 1,
      y: 0,
      duration: 0.5,
      stagger: delay,
      ease: 'power2.out',
    }
  );
};

export const animarAparicionModal = (overlayEl, contenidoEl) => {
  if (overlayEl) {
    gsap.fromTo(overlayEl, { opacity: 0 }, { opacity: 1, duration: 0.25 });
  }
  if (contenidoEl) {
    gsap.fromTo(
      contenidoEl,
      { opacity: 0, scale: 0.94, y: 15 },
      { opacity: 1, scale: 1, y: 0, duration: 0.35, ease: 'back.out(1.7)' }
    );
  }
};
