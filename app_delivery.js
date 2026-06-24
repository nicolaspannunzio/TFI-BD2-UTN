import { MongoClient, ObjectId } from 'mongodb';
import 'dotenv/config';

const url = process.env.MONGO_URI;
const client = new MongoClient(url);
const dbName = 'app_delivery';

async function main() {
    await client.connect();
    console.log('Conexión segura y exitosa con MongoDB Atlas');

    const db = client.db(dbName);

    // Objeto de prueba
    const productoDePrueba = {
        nombre: "Pizza de Fugazzeta",
        precio_unitario: 10300,
        categoria: "Pizzas",
        activo: true
    };

    // 1. CREATE (inserción)
    const creado = await crearProducto(db, productoDePrueba);
    const idGenerado = creado.insertedId.toString();

    // 2. READ (lectura - respeta baja lógica)
    const catalogo = await obtenerProductosActivos(db);
    console.log('\n--- CATÁLOGO DE PRODUCTOS VIGENTES ---');
    catalogo.forEach(prod => {
        console.log(`- [${prod._id}] ${prod.nombre} ($${prod.precio_unitario}) - Activo: ${prod.activo}`);
    });
    console.log('---------------------------------------\n');

    // 3. UPDATE (modificación de precio)
    await actualizarPrecioProducto(db, idGenerado, 11500);

    // 4. DELETE (baja lógica)
    await darBajaLogicaProducto(db, idGenerado);

    return 'Proceso completo ejecutado con éxito.';
}

// =========================================================================
// ========================== FUNCIONES CRUD ================================
// =========================================================================

async function crearProducto(db, nuevoProducto) {
    const resultado = await db.collection('productos').insertOne(nuevoProducto);

    console.log(`[CREATE] Producto insertado con éxito. ID: ${resultado.insertedId}`);
    return resultado;
}

async function obtenerProductosActivos(db) {
    const productos = await db.collection('productos').find({ activo: true }).toArray();

    console.log(`[READ] Se encontraron ${productos.length} productos activos en el catálogo.`);
    return productos;
}

async function actualizarPrecioProducto(db, idProducto, nuevoPrecio) {
    const resultado = await db.collection('productos').updateOne(
        { _id: new ObjectId(idProducto) },
        { $set: { precio_unitario: nuevoPrecio } }
    );

    console.log(`[UPDATE] Documentos modificados: ${resultado.modifiedCount}`);
    return resultado;
}

async function darBajaLogicaProducto(db, idProducto) {
    const resultado = await db.collection('productos').updateOne(
        { _id: new ObjectId(idProducto) },
        { $set: { activo: false } }
    );

    console.log(`[DELETE LÓGICO] Producto desactivado con éxito. Modificados: ${resultado.modifiedCount}`);
    return resultado;
}

try {
    const result = await main();
    console.log(result);
} catch (error) {
    console.error('Error crítico en la conexión con Atlas:', error);
} finally {
    await client.close();
}