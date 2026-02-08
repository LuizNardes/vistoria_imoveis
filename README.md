<div align="center">

# 📱 Vistoria de Imóveis

**Uma solução moderna e eficiente para vistorias imobiliárias digitais.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Core-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-purple?style=for-the-badge)](https://riverpod.dev)

</div>

---

## 📄 Sobre o Projeto

Este projeto é uma aplicação móvel desenvolvida em **Flutter** para realizar vistorias de imóveis de forma digital. O app permite gerenciar agendamentos, realizar checklists detalhados por cômodos, capturar evidências fotográficas e gerar automaticamente um Termo de Vistoria em PDF pronto para compartilhamento.

## ✨ Funcionalidades

- **🔐 Autenticação**: Login seguro via Firebase Auth.
- **📅 Gestão de Vistorias**: Listagem de vistorias agendadas, em andamento e concluídas.
- **📝 Checklist Detalhado**: Navegação intuitiva por cômodos (Sala, Cozinha, etc.) e itens.
- **📸 Captura de Mídia**: Câmera integrada com compressão automática e upload para Firebase Storage.
- **📡 Offline-First**: Suporte a funcionamento offline (sincronização automática quando a rede retorna).
- **📄 Relatórios PDF**: Geração de laudos completos com fotos e observações.
- **📤 Compartilhamento**: Envio direto do relatório via WhatsApp ou E-mail.

## 📱 Screenshots

<div align="center">
  <!-- Substitua pelos links reais das suas imagens -->
  <img src="https://via.placeholder.com/200x400?text=Login" alt="Login Screen" height="400" style="margin: 5px;"/>
  <img src="https://via.placeholder.com/200x400?text=Home" alt="Home Screen" height="400" style="margin: 5px;"/>
  <img src="https://via.placeholder.com/200x400?text=Checklist" alt="Checklist Screen" height="400" style="margin: 5px;"/>
</div>

## 🛠 Tech Stack

O projeto utiliza as melhores práticas e bibliotecas do ecossistema Flutter:

| Categoria | Tecnologia |
|-----------|------------|
| **Framework** | Flutter (Dart) |
| **Gerência de Estado** | Riverpod (Generator & Annotations) |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **Navegação** | GoRouter |
| **Imutabilidade** | Freezed & JsonSerializable |
| **PDF** | pdf & printing |

## 📂 Estrutura do Projeto

Arquitetura baseada em **Features** para escalabilidade:

```
lib/
├── core/                  # Configurações globais (Router, Theme, Exceptions)
├── features/
│   ├── auth/              # Login e Autenticação
│   ├── home/              # Dashboard e Listagem
│   ├── inspections/       # CRUD de Vistorias
│   ├── inspection_details/# Lógica de Cômodos, Itens e Fotos
│   └── reports/           # Geração e Visualização de PDF
├── shared/                # Widgets reutilizáveis
└── main.dart              # Entry point
```

## 🚀 Como Rodar o Projeto

### Pré-requisitos

- Flutter SDK instalado.
- Conta no Firebase.
- Firebase CLI (`npm install -g firebase-tools`).

### Passo a Passo

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/vistoria_imoveis.git
   cd vistoria_imoveis
   flutter pub get
   ```

2. **Configuração do Firebase**
   - Crie um projeto no Firebase Console.
   - Ative **Authentication** (Email/Password).
   - Crie o **Firestore Database** e **Storage**.
   - Configure no terminal:
     ```bash
     firebase login
     flutterfire configure
     ```

3. **Geração de Código**
   O projeto usa `build_runner` para gerar arquivos `.g.dart` e `.freezed.dart`.
   ```bash
   dart run build_runner build -d
   ```

4. **Executar**
   ```bash
   flutter run
   ```

## 🔒 Regras de Segurança (Dev)

Sugestão de regras para ambiente de desenvolvimento no Firebase:

<details>
<summary><strong>Firestore Rules</strong></summary>

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
</details>

<details>
<summary><strong>Storage Rules</strong></summary>

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
</details>

## 🤝 Como Contribuir

1. Faça um Fork do projeto.
2. Crie uma Branch para sua Feature (`git checkout -b feature/IncrivelFeature`).
3. Commit suas mudanças (`git commit -m 'Add: IncrivelFeature'`).
4. Push para a Branch (`git push origin feature/IncrivelFeature`).
5. Abra um Pull Request.

---

<div align="center">
  Desenvolvido com 💙 e Flutter
</div>