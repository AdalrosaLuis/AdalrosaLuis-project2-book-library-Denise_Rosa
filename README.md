A Minha Biblioteca (Projecttt)
Leva a tua estante contigo, onde quer que vás.
Secção 1: Visão Geral do Projeto
Descrição: Este projeto nasceu de uma necessidade real: organizar coleções de livros e manter um registo fiel do progresso de leitura. Com "A Minha Biblioteca", o utilizador pode registar cada obra, atualizar o número de páginas lidas e visualizar o seu avanço de forma gráfica. É mais do que uma simples lista; é um ecossistema digital que utiliza dados na nuvem para garantir que o histórico literário do utilizador nunca se perca, funcionando como um incentivo constante ao hábito da leitura.

Link para Vídeo Demo: [link do video]

Capturas de Ecrã: | imagens dos ecras

Secção 2: Lista de Funcionalidades
Controlo Total (CRUD): Adicionar, editar, consultar e remover livros da coleção pessoal.

Estatísticas de Leitura: Gráfico de barras dinâmico que mostra livros "Lidos", "A Ler" e "Quero Ler".

Sincronização na Nuvem: Dados guardados em tempo real através do Firebase.

Autenticação: Sistema de login seguro para proteção da biblioteca pessoal.

Modo Escuro: Interface adaptável para uma leitura noturna mais confortável.

Secção 3: Arquitetura
O projeto segue o padrão de Arquitetura em Camadas para garantir a separação de responsabilidades e facilitar a manutenção:

models/: Definição da estrutura de dados (ex: Book, UserModel).

services/: Lógica de comunicação com o Firebase (Firestore, Auth, Storage).

providers/: Gestão de estado global através do pacote Provider.

screens/: Interfaces de utilizador (UI) organizadas por módulos (Auth, Home, Profile).

widgets/: Componentes reutilizáveis como botões e cartões (cards).

Secção 4: Instruções de Configuração
Pré-requisitos:

Flutter SDK (v3.x ou superior)

Conta Firebase configurada

Passos para Execução:

Clonar o repositório para a máquina local.

Executar flutter pub get no terminal para instalar as dependências.

Adicionar o ficheiro google-services.json (Android) na pasta android/app/.

Lançar a aplicação com o comando flutter run.

Secção 5: Configuração do Firebase
Cloud Firestore: Estrutura de coleções organizada em users/{uid}/books/.

Firebase Storage: Pasta covers/ destinada ao armazenamento das imagens das capas.

Segurança: Regras configuradas para que apenas utilizadores autenticados possam aceder e gerir os seus próprios dados literários.

Secção 6: Documentação da API
API Externa: Google Books API.

Endpoint Utilizado:url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$cleanIsbn');

Função: A aplicação consome esta API para sugerir metadados e informações automáticas sobre os livros consultados.

Secção 7: Tecnologias Utilizadas
Framework: Flutter

Linguagem: Dart

Gestão de Estado: Provider

Backend: Firebase (Auth, Firestore, Storage)

Gráficos: Pacote fl_chart para a visualização de estatísticas.

Secção 8: Desafios e Soluções
Desafio: Garantir a inicialização do Firebase antes do carregamento da interface (UI).

Solução: Utilização de WidgetsFlutterBinding.ensureInitialized() e execução assíncrona do Firebase.initializeApp() no ponto de entrada (main.dart).

Desafio: Atualização em tempo real do gráfico de estatísticas após a inserção de novos dados.

Solução: Implementação do método notifyListeners() nos Providers para forçar a reconstrução dos widgets dependentes.

Secção 9: Melhorias Futuras
Nesta fase do projeto, as integrações de hardware foram iniciadas ao nível da interface, mas a persistência de dados será finalizada em atualizações futuras:

Scanner ISBN: Concluir a lógica de gravação para que o scanner preencha o formulário de forma automática.

Câmara & Storage: Implementar o carregamento (upload) efetivo das fotografias tiradas para o Firebase Storage.

Geolocalização (GPS): Ativar a funcionalidade de guardar as coordenadas das bibliotecas favoritas do utilizador.

Social: Criar um sistema de partilha de recomendações literárias entre utilizadores.

Secção 10: Créditos
Interface: Segue as diretrizes do Material Design 3.

Dados: Informações de livros providenciadas pela Google Books API.

Tutoriais: Baseado na documentação oficial do Flutter e nos codelabs do Firebase.