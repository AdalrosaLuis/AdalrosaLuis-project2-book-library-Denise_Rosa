# projecttt

A new Flutter project.
A Minha Biblioteca – Gestão Literária Pessoal
rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
Seção 1: Visão Geral do Projeto
Slogan: "Leva a tua estante contigo, onde quer que vás."

Descrição: Este projeto nasceu de uma necessidade real: organizar a minha coleção de livros e manter um registo fiel do que já li e do que ainda quero ler. 
Com "A Minha Biblioteca", o utilizador pode registar cada obra, atualizar o número de páginas lidas e ver o seu progresso de forma visual. É mais do que uma 
lista; é um incentivo à leitura, com os dados guardados na nuvem para nunca se perderem.

Capturas de Ecrã: (Deves incluir aqui o gráfico que mostra os teus 6 livros "Quero ler", o ecrã de login e a lista principal).

Seção 2: Lista de Recursos
Controlo Total (CRUD): Podes adicionar livros novos, editar os detalhes, consultá-los ou removê-los se já não fizerem parte da coleção.

Estatísticas de Leitura: Um gráfico de barras que se atualiza sozinho e mostra quantos livros tens "Lidos", "A Ler" ou na lista de espera.

Ferramentas Nativas: A app usa a câmara para guardar a foto da capa e o GPS para te ajudar a encontrar a biblioteca pública mais próxima.

Sugestões Inteligentes: Através da API da Google Books, a app recomenda outros livros do mesmo autor que estás a consultar.

Personalização: Inclui um modo escuro para quem gosta de organizar a biblioteca à noite com mais conforto.

Seção 3: Arquitetura
Organização: Separei o código de forma limpa: os ecrãs estão em screens, a lógica de dados em providers e as classes de base em models.

Gestão de Estado: Usei o Provider para que a app seja rápida e fluida. Temos o AuthProvider para as contas, o BookProvider para os livros e o SettingsProvider para o tema da app.

Seção 5: Configuração do Firebase
Estrutura: Uso o Firestore para guardar tudo. Cada utilizador tem o seu próprio espaço privado (users/{uid}/books), garantindo que a tua biblioteca é só tua.

Imagens: As capas dos livros que fotografas são guardadas no Firebase Storage para não pesarem na base de dados.

Segurança: As regras do Firebase estão configuradas para que ninguém consiga ler ou apagar os livros de outro utilizador.

Seção 8: Desafios e Soluções
Sincronização: O maior desafio foi garantir que, ao adicionar um livro, o gráfico de estatísticas mudasse logo.

Solução: Consegui resolver isto usando notifyListeners() no Provider, o que obriga a interface a redesenhar-se assim que os dados mudam no Firebase.

Seção 9: Melhorias Futuras
Leitor de Código de Barras: Infelizmente, tive dificuldades técnicas com a biblioteca de QR Code nesta fase, mas é a primeira coisa que quero adicionar na próxima atualização para facilitar o registo de livros pelo ISBN.

Partilha: Gostava de permitir que os utilizadores pudessem emprestar livros virtualmente entre si.
