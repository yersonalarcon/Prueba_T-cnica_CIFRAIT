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
    let connection;
    try {
        connection = await mysql.createConnection(dbConfig);
        console.log('Conexión a la base de datos exitosa.');

        const results = [];
        fs.createReadStream(filePath)
            .pipe(csv())
            .on('data', (data) => results.push(data))
            .on('end', async () => {
                console.log('Datos del CSV leídos correctamente. Iniciando la carga...');

                for (const row of results) {
                    try {
                        // 1. **Transformación:** Normalizar y limpiar los datos del CSV
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

                        // 2. **Carga:** Insertar la solicitud
                        await connection.query(
                            'INSERT INTO solicitudes (id_cliente, id_agente, asunto, descripcion, estado) VALUES (?, ?, ?, ?, ?)',
                            [idCliente, agente_id || null, asunto, descripcion, estado]
                        );

                    } catch (error) {
                        console.error('Error al procesar una fila:', error);
                    }
                }
                console.log('Carga de datos finalizada.');
            });

    } catch (error) {
        console.error('Error en el proceso ETL:', error);
    } finally {
        if (connection) connection.end();
    }
}

// Suponiendo un archivo CSV llamado 'solicitudes_externas.csv' con las siguientes columnas:
// cliente_email,asunto,descripcion,estado,agente_id
// ejemplo@cliente.com,Problema con mi cuenta,No puedo acceder,abierta,1

runETL();