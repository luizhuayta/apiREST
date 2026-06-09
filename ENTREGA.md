# Copia para entregar — TiendaVirtual API

Esta es la **versión diferenciada** del proyecto. Vive en la rama:

```
cursor/tienda-virtual-entrega-ac48
```

**No está en `main`.** Tu versión original sigue en `main` sin cambios.

## Cómo compartir

### Opción 1 — ZIP de la rama

```bash
git clone -b cursor/tienda-virtual-entrega-ac48 https://github.com/luizhuayta/apiREST.git tiendaVirtual-entrega
cd tiendaVirtual-entrega
zip -r ../tiendaVirtual-entrega.zip .
```

### Opción 2 — Enviar link de la rama

https://github.com/luizhuayta/apiREST/tree/cursor/tienda-virtual-entrega-ac48

## Diferencias con el proyecto base

| Aspecto | Proyecto base (`main`) | Esta copia |
|---------|------------------------|------------|
| Nombre | apiREST | **TiendaVirtual API** |
| Puerto | 3000 | **3500** |
| API version | v1 | **v2/tienda** |
| Endpoint rendimiento | `/heavy-process` | `/calcular-pedido` |
| Login | `/login` | `/acceso-personal` |
| Comentarios | `/comments` | `/resenas` |
| Tablas DB | users, comments | personal_tienda, resenas_clientes |

La lógica vulnerable y las pruebas JMeter (50 y 400 usuarios) se mantienen igual.
