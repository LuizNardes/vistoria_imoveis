📱 App de Vistoria Imobiliária (Flutter)
Este projeto é uma aplicação móvel desenvolvida em Flutter para realizar vistorias de imóveis de forma digital. O app permite gerenciar agendamentos, realizar checklists detalhados por cômodos, capturar evidências fotográficas e gerar automaticamente um Termo de Vistoria em PDF pronto para compartilhamento.

✨ Funcionalidades
Autenticação: Login seguro via Firebase Auth.

Gestão de Vistorias: Listagem de vistorias agendadas, em andamento e concluídas.

Checklist Detalhado: Navegação por cômodos (Sala, Cozinha, etc.) e itens (Paredes, Piso, etc.).

Captura de Mídia: Câmera integrada com compressão automática de imagens e upload para Firebase Storage.

Offline-First: Suporte a funcionamento offline (sincronização automática quando a rede retorna).

Relatórios: Geração de PDF compilando dados, observações e grade de fotos.

Compartilhamento: Envio direto do relatório via WhatsApp/E-mail.

🛠 Tech Stack
Framework: Flutter (Dart)

Gerenciamento de Estado: Riverpod (com Code Generation & Annotations)

Backend as a Service: Firebase

Auth (Autenticação)

Firestore (Banco de Dados NoSQL)

Storage (Armazenamento de Fotos)

Navegação: GoRouter

Imutabilidade & Serialização: Freezed & JsonSerializable

PDF: pdf & printing

📂 Estrutura do Projeto
O projeto segue uma arquitetura baseada em Features (Feature-first), facilitando a escalabilidade e manutenção:

lib/
├── core/                  # Configurações globais (Router, Theme, Exceptions)
├── features/
│   ├── auth/              # Login e Autenticação
│   ├── home/              # Dashboard e Listagem
│   ├── inspections/       # CRUD de Vistorias (Cabeçalho)
│   ├── inspection_details/# Lógica de Cômodos, Itens e Fotos
│   └── reports/           # Geração e Visualização de PDF
├── shared/                # Widgets reutilizáveis (Inputs, Cards, Loaders)
└── main.dart              # Ponto de entrada
🚀 Get Started (Como rodar o projeto)
Pré-requisitos
Flutter SDK instalado e configurado no PATH.

VS Code ou Android Studio.

Uma conta no Google para configurar o Firebase.

Firebase CLI instalado (npm install -g firebase-tools).

Passo 1: Clonar e Instalar Dependências
Bash
git clone https://seu-repositorio.git
cd seu-projeto
flutter pub get
Passo 2: Configuração do Firebase
Este projeto depende do Firebase. Você precisa configurar o seu próprio projeto no console do Firebase:

Crie um projeto em console.firebase.google.com.

Ative o Authentication (Email/Password).

Crie um banco Firestore e configure as regras de segurança.

Ative o Storage e configure as regras de segurança.

No terminal, faça login e configure o projeto localmente:

Bash
firebase login
flutterfire configure
Siga os passos na tela e selecione o projeto que você criou. Isso irá gerar/atualizar o arquivo lib/firebase_options.dart.

Passo 3: Geração de Código (Build Runner)
Como utilizamos Riverpod Generator e Freezed, é necessário rodar o gerador de código para criar os arquivos .g.dart e .freezed.dart.

Para rodar uma única vez:

Bash
dart run build_runner build -d
Para deixar rodando em modo "watch" (recomendado durante o desenvolvimento):

Bash
dart run build_runner watch -d
(Mantenha este terminal aberto enquanto programa).

Passo 4: Rodar o App
Conecte um dispositivo físico ou inicie um emulador e rode:

Bash
flutter run
🔒 Regras do Firebase (Sugestão para Dev)
Para desenvolvimento, você pode usar as seguintes regras no Firebase Console (Lembre-se de restringir mais para produção):

Firestore Rules:

JavaScript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
Storage Rules:

JavaScript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
🤝 Como Contribuir
Crie uma Branch para sua feature (git checkout -b feature/MinhaNovaFeature).

Não altere arquivos .g.dart ou .freezed.dart manualmente. Sempre use o build_runner.

Commit suas mudanças (git commit -m 'Add: nova funcionalidade').

Push para a Branch (git push origin feature/MinhaNovaFeature).

Abra um Pull Request.

Desenvolvido com 💙 e Flutter.