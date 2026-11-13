import 'package:flutter/material.dart';

import '../app.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final activa = auth.isAuthenticated;
    final colores = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Información de la sesión',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Nombre'),
                subtitle: Text(auth.nombre ?? '—'),
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Correo electrónico'),
                subtitle: Text(auth.email ?? '—'),
              ),
              ListTile(
                leading: Icon(
                  activa ? Icons.verified_user_outlined : Icons.lock_outline,
                  color: activa ? colores.primary : colores.error,
                ),
                title: const Text('Estado de autenticación'),
                subtitle: Text(activa ? 'Sesión activa' : 'Sin sesión'),
              ),
              ListTile(
                leading: const Icon(Icons.key_outlined),
                title: const Text('Token almacenado'),
                subtitle: Text(
                  auth.hasToken ? 'Sí (${auth.tokenPreview})' : 'No',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => AuthScope.of(context).logout(),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}