import React, { useEffect, useRef } from 'react';
import * as THREE from 'three';

export const Crest3D = ({ className = '', style = {} }) => {
  const containerRef = useRef(null);
  const rendererRef = useRef(null);
  const cameraRef = useRef(null);
  const animationFrameIdRef = useRef(null);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const width = container.clientWidth || 300;
    const height = container.clientHeight || 300;

    // 1. Escena y Cámara
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 1000);
    camera.position.set(0, 0, 5.5);
    cameraRef.current = camera;

    // 2. Renderizador optimizado
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'high-performance' });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2)); // Limitar a 2x para pantallas Retina
    renderer.shadowMap.enabled = true;
    container.appendChild(renderer.domElement);
    rendererRef.current = renderer;

    // 3. Luces
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.85);
    scene.add(ambientLight);

    const pointLight = new THREE.PointLight(0xFEE11A, 2, 50); // Amarillo Eléctrico
    pointLight.position.set(3, 4, 5);
    scene.add(pointLight);

    const secondaryLight = new THREE.PointLight(0x007030, 2, 50); // Verde UO
    secondaryLight.position.set(-3, -3, 3);
    scene.add(secondaryLight);

    // 4. Geometrías: Emblema Institucional Octogonal 3D con Anillo de Excelencia
    const group = new THREE.Group();

    // Anillo Exterior Dorado (Excelencia Profesional)
    const torusGeo = new THREE.TorusGeometry(1.6, 0.08, 16, 100);
    const torusMat = new THREE.MeshStandardMaterial({
      color: 0xF5A604, // Amarillo Zapallo
      roughness: 0.3,
      metalness: 0.85,
    });
    const torus = new THREE.Mesh(torusGeo, torusMat);
    group.add(torus);

    // Anillo Secundario Fino
    const innerRingGeo = new THREE.TorusGeometry(1.4, 0.03, 16, 80);
    const innerRingMat = new THREE.MeshStandardMaterial({
      color: 0xFEE11A, // Amarillo Eléctrico
      roughness: 0.2,
      metalness: 0.9,
    });
    const innerRing = new THREE.Mesh(innerRingGeo, innerRingMat);
    group.add(innerRing);

    // Prisma Central Institucional (Verde UO)
    const prismGeo = new THREE.CylinderGeometry(1.1, 1.1, 0.25, 8); // Octógono de administración
    const prismMat = new THREE.MeshStandardMaterial({
      color: 0x007030, // Verde UO
      roughness: 0.4,
      metalness: 0.6,
    });
    const prism = new THREE.Mesh(prismGeo, prismMat);
    prism.rotation.x = Math.PI / 2;
    group.add(prism);

    // Núcleo Diamante Verde Bosque
    const coreGeo = new THREE.OctahedronGeometry(0.65, 0);
    const coreMat = new THREE.MeshStandardMaterial({
      color: 0x004D30, // Verde Bosque
      roughness: 0.2,
      metalness: 0.7,
      wireframe: false,
    });
    const core = new THREE.Mesh(coreGeo, coreMat);
    group.add(core);

    // Nodos Orbitantes de las Provincias de Junín (Huancayo, Concepción, Chupaca, Jauja, Tarma, Yauli, Chanchamayo, Satipo, Junín)
    const orbitNodes = [];
    const nodeCount = 9;
    const nodeGeo = new THREE.SphereGeometry(0.09, 16, 16);
    const nodeMat = new THREE.MeshStandardMaterial({ color: 0xFEE11A, metalness: 0.9, roughness: 0.1 });

    for (let i = 0; i < nodeCount; i++) {
      const angle = (i / nodeCount) * Math.PI * 2;
      const radius = 1.9;
      const nodeMesh = new THREE.Mesh(nodeGeo, nodeMat);
      nodeMesh.position.set(Math.cos(angle) * radius, Math.sin(angle) * radius, 0);
      group.add(nodeMesh);
      orbitNodes.push(nodeMesh);
    }

    scene.add(group);

    // 5. Interacción con el cursor del ratón
    let mouseX = 0;
    let mouseY = 0;
    let targetX = 0;
    let targetY = 0;

    const onMouseMove = (event) => {
      const rect = container.getBoundingClientRect();
      const x = event.clientX - rect.left - rect.width / 2;
      const y = event.clientY - rect.top - rect.height / 2;
      targetX = (x / rect.width) * 0.8;
      targetY = (y / rect.height) * 0.8;
    };

    container.addEventListener('mousemove', onMouseMove);

    // 6. Resize Handler dinámico
    const handleResize = () => {
      if (!container || !rendererRef.current || !cameraRef.current) return;
      const newWidth = container.clientWidth;
      const newHeight = container.clientHeight;
      cameraRef.current.aspect = newWidth / newHeight;
      cameraRef.current.updateProjectionMatrix();
      rendererRef.current.setSize(newWidth, newHeight);
    };

    window.addEventListener('resize', handleResize);

    // 7. Ciclo de Animación a 60 FPS
    let clock = new THREE.Clock();
    const animate = () => {
      const elapsedTime = clock.getElapsedTime();

      // Rotación suave del emblema
      group.rotation.y = elapsedTime * 0.4 + mouseX;
      group.rotation.x = Math.sin(elapsedTime * 0.3) * 0.15 + mouseY;

      // Pulsación del núcleo
      const scale = 1 + Math.sin(elapsedTime * 2) * 0.05;
      core.scale.set(scale, scale, scale);

      // Interpolación suave hacia la posición del cursor
      mouseX += (targetX - mouseX) * 0.05;
      mouseY += (targetY - mouseY) * 0.05;

      renderer.render(scene, camera);
      animationFrameIdRef.current = requestAnimationFrame(animate);
    };

    animate();

    // 8. Clean-up estricto en el desmontaje (Cero fugas de memoria)
    return () => {
      if (animationFrameIdRef.current) {
        cancelAnimationFrame(animationFrameIdRef.current);
      }
      window.removeEventListener('resize', handleResize);
      container.removeEventListener('mousemove', onMouseMove);

      torusGeo.dispose();
      torusMat.dispose();
      innerRingGeo.dispose();
      innerRingMat.dispose();
      prismGeo.dispose();
      prismMat.dispose();
      coreGeo.dispose();
      coreMat.dispose();
      nodeGeo.dispose();
      nodeMat.dispose();

      if (renderer.domElement && container.contains(renderer.domElement)) {
        container.removeChild(renderer.domElement);
      }
      renderer.dispose();
    };
  }, []);

  return (
    <div
      ref={containerRef}
      className={className}
      style={{
        width: '100%',
        height: '100%',
        minHeight: '280px',
        position: 'relative',
        cursor: 'grab',
        ...style,
      }}
      title="Emblema Institucional 3D Interactivo CORLAD Junín (Mueve el cursor)"
    />
  );
};
