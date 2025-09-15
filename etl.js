const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const csv = require('csv-parser');

// Configuración de la base de datos
const dbConfig = {
    host: 'localhost',
    user: 'root', 
    password: '12345', 
    database: 'sistema_soporte'
};

const filePath = path.join(__dirname, 'solicitudes_externas.csv');

async function runETL() {
    console.log('Iniciando el proceso ETL...');

    let connection;
    try {
        // Conexión a la base de datos
        connection = await mysql.createConnection(dbConfig);
        console.log('Conexión a la base de datos exitosa.');
        
        const results = [];
        const parser = fs.createReadStream(filePath).pipe(csv());

        // Manejar el evento de datos
        parser.on('data', (data) => results.push(data));

        // Manejar el evento de fin de lectura
        await new Promise((resolve) => parser.on('end', resolve));

        console.log('Datos del CSV leídos correctamente. Iniciando la carga...');

        // Procesar y cargar cada fila
        for (const row of results) {
            try {
                const {
                    cliente_email,
                    asunto,
                    descripcion,
                    estado,
                    agente_id
                } = row;

                // Verificar si el cliente ya existe
                let [clientesExistentes] = await connection.query(
                    'SELECT id_cliente FROM clientes WHERE email = ?',
                    [cliente_email]
                );

                let idCliente;
                if (clientesExistentes.length === 0) {
                    // Si el cliente no existe, crearlo
                    const [nuevoCliente] = await connection.query(
                        'INSERT INTO clientes (nombre, email) VALUES (?, ?)',
                        [cliente_email, cliente_email]
                    );
                    idCliente = nuevoCliente.insertId;
                    console.log(`Cliente nuevo creado con ID: ${idCliente}`);
                } else {
                    idCliente = clientesExistentes[0].id_cliente;
                }

                // Insertar la solicitud en la tabla
                await connection.query(
                    'INSERT INTO solicitudes (id_cliente, id_agente, asunto, descripcion, estado) VALUES (?, ?, ?, ?, ?)',
                    [idCliente, agente_id || null, asunto, descripcion, estado]
                );
                
            } catch (error) {
                console.error('Error al procesar una fila:', error.message);
            }
        }
        
        console.log('Carga de datos finalizada con éxito.');

    } catch (error) {
        console.error('Error en el proceso ETL:', error.message);
        if (error.sqlState) {
            console.error('SQL State:', error.sqlState);
        }
    } finally {
        if (connection) {
            await connection.end();
            console.log('Conexión a la base de datos cerrada.');
        }
    }
}

runETL();