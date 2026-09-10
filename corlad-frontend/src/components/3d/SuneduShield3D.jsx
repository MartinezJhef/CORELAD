import React, { useEffect, useRef } from 'react';
import * as THREE from 'three';

/**
 * Componente Three.js para la Verificación Digital Universitaria SUNEDU / CORLAD Junín.
 * Representa el Escudo de Autenticidad con anillos orbitales interactivos y nodos de fe pública.
 * Optimizado con limpieza estricta de geometrías y ciclo de render para evitar fugas de memoria.
 */
export const SuneduShield3D = ({ isValidated = false, className = '', style = {} }) => {
  const containerRef = useRef(null);
  const rendererRef = useRef(null);
  const cameraRef = useRef(null);
  const animationFrameIdRef = useRef(null);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const width = container.clientWidth || 280;
    const height = container.clientHeight || 280;

    // 1. Escena y Cámara
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 1000);
    camera.position.set(0, 0, 5.0);
    cameraRef.current = camera;

    // 2. Renderizador WebGL con alta precisión y transparencia
    const renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: true,
      powerPreference: 'high-performance',
    });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.shadowMap.enabled = true;
    container.appendChild(renderer.domElement);
    rendererRef.current = renderer;

    // 3. Luces
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.9);
    scene.add(ambientLight);

    // Luz dorada de excelencia académica (#F5A604)
    const goldLight = new THREE.PointLight(0xF5A604, 2.5, 30);
    goldLight.position.set(3, 3, 4);
    scene.add(goldLight);

    // Luz verde institucional CORLAD (#007030)
    const greenLight = new THREE.PointLight(0x007030, 2.5, 30);
    greenLight.position.set(-3, -3, 3);
    scene.add(greenLight);

    // 4. Grupo 3D Principal
    const mainGroup = new THREE.Group();

    // Núcleo: Octaedro / Gema de Fe Pública
    const coreGeo = new THREE.OctahedronGeometry(1.0, 0);
    const coreMat = new THREE.MeshStandardMaterial({
      color: isValidated ? 0x007030 : 0xF5A604,
      roughness: 0.25,
      metalness: 0.85,
      wireframe: false,
    });
    const coreMesh = new THREE.Mesh(coreGeo, coreMat);
    mainGroup.add(coreMesh);

    // Corona Externa Wireframe
    const wireGeo = new THREE.OctahedronGeometry(1.25, 1);
    const wireMat = new THREE.MeshBasicMaterial({
      color: isValidated ? 0xFEE11A : 0x004D30,
      wireframe: true,
      transparent: true,
      opacity: 0.65,
    });
    const wireMesh = new THREE.Mesh(wireGeo, wireMat);
    mainGroup.add(wireMesh);

    // Anillo Orbital 1 (Interoperabilidad SUNEDU - PIDE)
    const ring1Geo = new THREE.TorusGeometry(1.65, 0.035, 16, 100);
    const ring1Mat = new THREE.MeshStandardMaterial({
      color: 0xFEE11A,
      roughness: 0.3,
      metalness: 0.9,
    });
    const ring1 = new THREE.Mesh(ring1Geo, ring1Mat);
    ring1.rotation.x = Math.PI / 3;
    mainGroup.add(ring1);

    // Anillo Orbital 2 (Validación CORLAD Junín)
    const ring2Geo = new THREE.TorusGeometry(1.85, 0.025, 16, 100);
    const ring2Mat = new THREE.MeshStandardMaterial({
      color: 0x007030,
      roughness: 0.4,
      metalness: 0.8,
    });
    const ring2 = new THREE.Mesh(ring2Geo, ring2Mat);
    ring2.rotation.y = Math.PI / 4;
    mainGroup.add(ring2);

    // Nodos de Verificación de Datos (Esferas satélites)
    const nodeGeo = new THREE.SphereGeometry(0.09, 16, 16);
    const nodeMat = new THREE.MeshStandardMaterial({
      color: 0xFFFFFF,
      emissive: isValidated ? 0x007030 : 0xF5A604,
      emissiveIntensity: 0.8,
    });

    const satellites = [];
    for (let i = 0; i < 4; i++) {
      const satellite = new THREE.Mesh(nodeGeo, nodeMat);
      mainGroup.add(satellite);
      satellites.push({
        mesh: satellite,
        angle: (i * Math.PI) / 2,
        radius: 1.65,
        speed: 0.02 + i * 0.005,
      });
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

    // 6. Bucle de animación suave a 60 FPS
    let clock = new THREE.Clock();

    const animate = () => {
      animationFrameIdRef.current = requestAnimationFrame(animate);
      const elapsedTime = clock.getElapsedTime();

      // Rotación suave del escudo
      coreMesh.rotation.y = elapsedTime * 0.5;
      coreMesh.rotation.x = Math.sin(elapsedTime * 0.3) * 0.2;

      wireMesh.rotation.y = -elapsedTime * 0.3;
      wireMesh.rotation.z = Math.cos(elapsedTime * 0.2) * 0.15;

      ring1.rotation.z = elapsedTime * 0.4;
      ring2.rotation.x = elapsedTime * 0.35;

      // Movimiento orbital de los satélites
      satellites.forEach((sat) => {
        sat.angle += sat.speed;
        sat.mesh.position.x = Math.cos(sat.angle) * sat.radius;
        sat.mesh.position.y = Math.sin(sat.angle) * Math.cos(Math.PI / 3) * sat.radius;
        sat.mesh.position.z = Math.sin(sat.angle) * Math.sin(Math.PI / 3) * sat.radius;
      });

      renderer.render(scene, camera);
    };

    animate();

    // 7. Limpieza estricta en el desmontaje (Cero fugas de memoria)
    return () => {
      window.removeEventListener('resize', handleResize);
      if (animationFrameIdRef.current) {
        cancelAnimationFrame(animationFrameIdRef.current);
      }

      coreGeo.dispose();
      coreMat.dispose();
      wireGeo.dispose();
      wireMat.dispose();
      ring1Geo.dispose();
      ring1Mat.dispose();
      ring2Geo.dispose();
      ring2Mat.dispose();
      nodeGeo.dispose();
      nodeMat.dispose();

      if (renderer && renderer.domElement && container.contains(renderer.domElement)) {
        container.removeChild(renderer.domElement);
      }
      renderer.dispose();
    };
  }, [isValidated]);

  return (
    <div
      ref={containerRef}
      className={`relative flex items-center justify-center pointer-events-none ${className}`}
      style={{ width: '100%', height: '100%', minHeight: '220px', ...style }}
    />
  );
};

export default SuneduShield3D;
