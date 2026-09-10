import React, { useEffect, useRef } from 'react';
import * as THREE from 'three';

/**
 * Componente Three.js para la Credencial Institucional (Carnet de Colegiado) del CORLAD Junín.
 * Renderiza el Emblema Medallón 3D de Colegiatura Oficial con relieve metálico, estrellas doradas y partículas orbitales.
 * Cumple con limpieza estricta de memoria, render loop seguro y pointer-events-none.
 */
export const CarnetEmblema3D = ({ matricula = 'CORLAD-JUN', className = '', style = {} }) => {
  const containerRef = useRef(null);
  const rendererRef = useRef(null);
  const cameraRef = useRef(null);
  const animationFrameIdRef = useRef(null);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const width = container.clientWidth || 240;
    const height = container.clientHeight || 240;

    // 1. Escena y Cámara
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 1000);
    camera.position.set(0, 0, 4.2);
    cameraRef.current = camera;

    // 2. Renderizador WebGL con alta precisión y fondo transparente
    const renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: true,
      powerPreference: 'high-performance',
    });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    container.appendChild(renderer.domElement);
    rendererRef.current = renderer;

    // 3. Luces
    const ambientLight = new THREE.AmbientLight(0xffffff, 1.1);
    scene.add(ambientLight);

    // Luz dorada brillante (#F5A604)
    const goldLight = new THREE.PointLight(0xF5A604, 3.0, 25);
    goldLight.position.set(2.5, 3, 3.5);
    scene.add(goldLight);

    // Luz verde esmeralda institucional (#007030)
    const greenLight = new THREE.PointLight(0x007030, 2.8, 25);
    greenLight.position.set(-2.5, -2.5, 3);
    scene.add(greenLight);

    // 4. Grupo 3D Principal
    const mainGroup = new THREE.Group();

    // Medallón base exterior (Bisel dorado)
    const coinGeo = new THREE.CylinderGeometry(1.2, 1.2, 0.12, 48);
    const coinMat = new THREE.MeshStandardMaterial({
      color: 0xF5A604,
      metalness: 0.9,
      roughness: 0.2,
    });
    const coinMesh = new THREE.Mesh(coinGeo, coinMat);
    coinMesh.rotation.x = Math.PI / 2;
    mainGroup.add(coinMesh);

    // Núcleo Interior Verde UO (#007030)
    const innerGeo = new THREE.CylinderGeometry(1.02, 1.02, 0.14, 48);
    const innerMat = new THREE.MeshStandardMaterial({
      color: 0x007030,
      metalness: 0.65,
      roughness: 0.35,
    });
    const innerMesh = new THREE.Mesh(innerGeo, innerMat);
    innerMesh.rotation.x = Math.PI / 2;
    mainGroup.add(innerMesh);

    // Estrella Central de Honor Deontológico (Dodecaedro dorado)
    const starGeo = new THREE.DodecahedronGeometry(0.48, 0);
    const starMat = new THREE.MeshStandardMaterial({
      color: 0xFEE11A,
      metalness: 0.95,
      roughness: 0.15,
      emissive: 0xF5A604,
      emissiveIntensity: 0.3,
    });
    const starMesh = new THREE.Mesh(starGeo, starMat);
    starMesh.position.z = 0.12;
    mainGroup.add(starMesh);

    // Anillo exterior de fe pública
    const ringGeo = new THREE.TorusGeometry(1.42, 0.03, 16, 64);
    const ringMat = new THREE.MeshStandardMaterial({
      color: 0xFEE11A,
      metalness: 0.9,
      roughness: 0.2,
    });
    const ringMesh = new THREE.Mesh(ringGeo, ringMat);
    mainGroup.add(ringMesh);

    // Partículas de seguridad holográfica (8 puntos satelitales)
    const particleGeo = new THREE.SphereGeometry(0.045, 12, 12);
    const particleMat = new THREE.MeshStandardMaterial({
      color: 0xFFFFFF,
      emissive: 0xFEE11A,
      emissiveIntensity: 0.9,
    });

    const particles = [];
    for (let i = 0; i < 8; i++) {
      const p = new THREE.Mesh(particleGeo, particleMat);
      const angle = (i / 8) * Math.PI * 2;
      p.position.set(Math.cos(angle) * 1.3, Math.sin(angle) * 1.3, 0.08);
      mainGroup.add(p);
      particles.push({ mesh: p, angle });
    }

    scene.add(mainGroup);

    // 5. Redimensionamiento adaptativo
    const handleResize = () => {
      if (!container || !renderer || !camera) return;
      const newWidth = container.clientWidth;
      const newHeight = container.clientHeight;
      camera.aspect = newWidth / newHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(newWidth, newHeight);
      renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    };

    window.addEventListener('resize', handleResize);

    // 6. Bucle de animación a 60 FPS con oscilación suave
    let clock = new THREE.Clock();

    const animate = () => {
      animationFrameIdRef.current = requestAnimationFrame(animate);
      const elapsedTime = clock.getElapsedTime();

      // Rotación suave del medallón
      mainGroup.rotation.y = Math.sin(elapsedTime * 0.8) * 0.35;
      mainGroup.rotation.x = Math.cos(elapsedTime * 0.6) * 0.2;

      // Giro dinámico de la estrella central
      starMesh.rotation.y = elapsedTime * 1.2;
      starMesh.rotation.z = elapsedTime * 0.8;

      // Órbita sutil del anillo
      ringMesh.rotation.z = -elapsedTime * 0.4;

      renderer.render(scene, camera);
    };

    animate();

    // 7. Limpieza estricta de memoria al desmontar
    return () => {
      window.removeEventListener('resize', handleResize);
      if (animationFrameIdRef.current) {
        cancelAnimationFrame(animationFrameIdRef.current);
      }

      coinGeo.dispose();
      coinMat.dispose();
      innerGeo.dispose();
      innerMat.dispose();
      starGeo.dispose();
      starMat.dispose();
      ringGeo.dispose();
      ringMat.dispose();
      particleGeo.dispose();
      particleMat.dispose();

      if (renderer && renderer.domElement && container.contains(renderer.domElement)) {
        container.removeChild(renderer.domElement);
      }
      renderer.dispose();
    };
  }, [matricula]);

  return (
    <div
      ref={containerRef}
      className={`relative flex items-center justify-center pointer-events-none ${className}`}
      style={{ width: '100%', height: '100%', minHeight: '180px', ...style }}
    />
  );
};

export default CarnetEmblema3D;
