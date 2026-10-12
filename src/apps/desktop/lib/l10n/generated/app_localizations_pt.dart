// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get panelExplorer => 'Explorador';

  @override
  String get panelGit => 'Git';

  @override
  String get panelHistory => 'Histórico';

  @override
  String get panelPullRequest => 'Pull request';

  @override
  String get panelOverview => 'Resumo';

  @override
  String get panelStatus => 'Status';

  @override
  String get modeSource => 'Código';

  @override
  String get modeSplit => 'Dividido';

  @override
  String get modePreview => 'Prévia';

  @override
  String get commonAskingGit => 'Perguntando ao git…';

  @override
  String get commonWaitingForApproval =>
      'Aguardando sua aprovação para ler o repositório.';

  @override
  String get commonNoSpaceOpen => 'Nenhum espaço aberto.';

  @override
  String get commonNoSpaceOpenStatus => 'nenhum espaço aberto';

  @override
  String get commonUnsaved => 'Não salvo';

  @override
  String get commonReload => 'Recarregar';

  @override
  String get commonPush => 'Push';

  @override
  String get commonPull => 'Pull';

  @override
  String get commonFetch => 'Fetch';

  @override
  String get commonSaveAndClose => 'Salvar e fechar';

  @override
  String get commonDiscardAndClose => 'Descartar e fechar';

  @override
  String get commonTheOpenDocument => 'O documento aberto';

  @override
  String commonHasUnsavedChanges(String name) {
    return '$name tem alterações não salvas.';
  }

  @override
  String get commonNotOnABranch => 'Fora de uma branch';

  @override
  String get commonNoBranch => 'sem branch';

  @override
  String get commonChooseADocument => 'Escolha um documento no explorador.';

  @override
  String get commonReadingTheDocument => 'Lendo o documento…';

  @override
  String get documentNotFound => 'Esse documento não está mais lá.';

  @override
  String get documentPermissionDenied =>
      'O TOM não tem permissão para ler esse documento.';

  @override
  String get documentNotUtf8 =>
      'Esse arquivo não é texto UTF-8, então o TOM não vai abri-lo.';

  @override
  String get documentUnreadable => 'Não foi possível ler esse documento.';

  @override
  String get gitNotInstalled => 'O TOM não encontrou o git nesta máquina.';

  @override
  String get gitNotARepository =>
      'Essa pasta não está dentro de um repositório Git.';

  @override
  String get gitTimedOut => 'O git demorou demais para responder.';

  @override
  String get conflictAcceptCurrent => 'Aceitar Alteração Atual';

  @override
  String get conflictAcceptIncoming => 'Aceitar Alteração de Entrada';

  @override
  String get conflictAcceptBoth => 'Aceitar Ambas as Alterações';

  @override
  String get conflictCurrentChange => 'Alteração Atual';

  @override
  String get conflictIncomingChange => 'Alteração de Entrada';

  @override
  String get fileStateModified => 'Modificado';

  @override
  String get fileStateAdded => 'Adicionado';

  @override
  String get fileStateDeleted => 'Excluído';

  @override
  String get fileStateRenamed => 'Renomeado';

  @override
  String get fileStateUntracked => 'Novo — o git ainda não sabe dele';

  @override
  String get fileStateConflicted =>
      'Em conflito — resolva antes de fazer commit';

  @override
  String get revealInFinder => 'Mostrar no Finder';

  @override
  String get revealInExplorer => 'Mostrar no Explorador de Arquivos';

  @override
  String get revealInFiles => 'Mostrar em Arquivos';

  @override
  String get openRepositoryInFinder => 'Abrir repositório no Finder';

  @override
  String get openRepositoryInExplorer =>
      'Abrir repositório no Explorador de Arquivos';

  @override
  String get openRepositoryInFiles => 'Abrir repositório em Arquivos';

  @override
  String get whenJustNow => 'agora mesmo';

  @override
  String whenMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count minutos',
      one: 'há 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String whenHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count horas',
      one: 'há 1 hora',
    );
    return '$_temp0';
  }

  @override
  String whenDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String whenMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count meses',
      one: 'há 1 mês',
    );
    return '$_temp0';
  }

  @override
  String whenYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count anos',
      one: 'há 1 ano',
    );
    return '$_temp0';
  }

  @override
  String get preferencesTooltip => 'Preferências';

  @override
  String get preferencesTheme => 'TEMA';

  @override
  String get preferencesThemeSystem => 'Sistema';

  @override
  String get preferencesThemeLight => 'Claro';

  @override
  String get preferencesThemeDark => 'Escuro';

  @override
  String get preferencesLanguage => 'IDIOMA';

  @override
  String get preferencesLanguageSystem => 'Sistema';

  @override
  String get preferencesShowFormattingBar => 'Mostrar a barra de formatação';

  @override
  String get preferencesOpenFile => 'Abrir preferences.json';

  @override
  String preferencesChangedOnDisk(String name) {
    return '$name mudou no disco enquanto você o editava.';
  }

  @override
  String get preferencesKeepMine => 'Manter o meu';

  @override
  String get homeRecent => 'RECENTES';

  @override
  String get homeForgetSpace => 'Esquecer este espaço';

  @override
  String get homeTagline =>
      'Um cliente Git feito para documentação, não para código.';

  @override
  String get homeChooseFolder => 'Escolher pasta…';

  @override
  String get homeChooseAnotherFolder => 'Escolher outra pasta…';

  @override
  String get homeOpening => 'Abrindo…';

  @override
  String get homeWaitingForApproval => 'Aguardando a sua aprovação…';

  @override
  String homeNotOpenedDenied(String folder) {
    return '$folder não foi aberta — um comando foi negado.';
  }

  @override
  String get homeCloneFromUrl => 'Clonar de uma URL';

  @override
  String get homeClone => 'Clonar';

  @override
  String get homeCloning => 'Clonando…';

  @override
  String get homeCloneHint =>
      'Cole o endereço. Em seguida você escolhe a pasta, e ela abre como um espaço.';

  @override
  String get homeCloneStarting => 'Iniciando';

  @override
  String get homeCloneCounting => 'Contando objetos';

  @override
  String get homeCloneReceiving => 'Recebendo objetos';

  @override
  String get homeCloneResolving => 'Resolvendo deltas';

  @override
  String get homeCloneUpdating => 'Atualizando arquivos';

  @override
  String homeClonePhase(String stage, String folder) {
    return '$stage  —  em $folder';
  }

  @override
  String homeClonePhasePercent(String stage, int percent, String folder) {
    return '$stage · $percent%  —  em $folder';
  }

  @override
  String get homeCloneNoRepository => 'Não há repositório nesse endereço.';

  @override
  String homeCloneCredentials(String host) {
    return 'O git recusou as credenciais para $host. Entre com o seu próprio git e tente de novo.';
  }

  @override
  String get homeCloneCredentialsAnywhere =>
      'O git recusou as credenciais para esse endereço. Entre com o seu próprio git e tente de novo.';

  @override
  String get homeCloneNoNetwork =>
      'Sem rede — não foi possível alcançar o endereço.';

  @override
  String get homeCloneTimedOut =>
      'O endereço não respondeu a tempo — tente de novo.';

  @override
  String homeCloneFolderTaken(String folder) {
    return '$folder já existe — escolha outra pasta.';
  }

  @override
  String get homeCloneNoGit => 'O git não está instalado nesta máquina.';

  @override
  String get homeCloneFailed => 'O git não conseguiu clonar esse endereço.';

  @override
  String get homeRefusedFolderMissing => 'Essa pasta não está mais lá';

  @override
  String get homeRefusedFolderMissingWhy =>
      'Talvez esteja em um disco desconectado, ou foi movida ou renomeada fora do TOM.';

  @override
  String get homeRefusedNoGit => 'O TOM não encontra o git nesta máquina';

  @override
  String get homeRefusedNoGitWhy =>
      'O TOM usa o git que você já tem. Instale-o, ou confira se ele está no seu PATH, e tente de novo.';

  @override
  String get aboutRow => 'Sobre o TOM';

  @override
  String get aboutUpdateAvailable => 'Atualização disponível';

  @override
  String get aboutTagline => 'Team-Oriented Markdown';

  @override
  String get aboutVersion => 'Versão';

  @override
  String get aboutPlatform => 'Plataforma';

  @override
  String get aboutLicense => 'Licença';

  @override
  String get aboutSource => 'Código no GitHub';

  @override
  String get aboutLicenses => 'Licenças';

  @override
  String get aboutReleaseNotes => 'Notas da versão';

  @override
  String get aboutClose => 'Fechar';

  @override
  String get aboutUpdates => 'ATUALIZAÇÕES';

  @override
  String get aboutCheck => 'Procurar atualizações';

  @override
  String get aboutNoRelease => 'Ainda não há versão publicada.';

  @override
  String get aboutAsking => 'Perguntando ao GitHub pela última versão…';

  @override
  String aboutUpToDate(String version) {
    return 'O TOM $version é a versão mais recente.';
  }

  @override
  String aboutChecked(String time) {
    return 'Verificado às $time.';
  }

  @override
  String aboutNewer(String version, String running) {
    return 'O TOM $version está disponível. Você tem a $running.';
  }

  @override
  String get aboutWhatsNew => 'O que há de novo';

  @override
  String get aboutFailed => 'O GitHub não respondeu.';

  @override
  String get aboutTryAgain => 'Tentar de novo';

  @override
  String get preferencesCheckForUpdates =>
      'Procurar atualizações ao abrir o TOM';

  @override
  String shellUpdateAvailable(String version) {
    return 'Atualização disponível: $version';
  }

  @override
  String get homeRefusedGitTooOld => 'O TOM precisa do git 2.41 ou mais novo.';

  @override
  String homeRefusedGitTooOldWhy(String version) {
    return 'Esta máquina tem o $version.';
  }

  @override
  String get homeRefusedUnopened => 'Não foi possível abrir essa pasta';

  @override
  String get homeRefusedUnopenedWhy =>
      'O git ou o disco recusou sem dizer por quê. Tente de novo, ou escolha outra pasta.';

  @override
  String shellChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações',
      one: '1 alteração',
    );
    return '$_temp0';
  }

  @override
  String shellCaret(int line, int column) {
    return 'Ln $line, Col $column';
  }

  @override
  String get shellSaving => 'Salvando…';

  @override
  String get shellSaved => 'Salvo';

  @override
  String get shellNotSaved => 'Não foi salvo';

  @override
  String shellReadingVersion(String sha, String author, String when) {
    return 'Lendo $sha · $author · $when';
  }

  @override
  String get shellBackToNow => 'Voltar ao agora';

  @override
  String get shellReadOnly => 'Somente leitura';

  @override
  String get shellKindMarkdown => 'Markdown';

  @override
  String get shellKindJson => 'JSON';

  @override
  String get shellKindYaml => 'YAML';

  @override
  String get shellKindToml => 'TOML';

  @override
  String get shellKindXml => 'XML';

  @override
  String get shellKindHtml => 'HTML';

  @override
  String get shellKindCss => 'CSS';

  @override
  String get shellKindJavaScript => 'JavaScript';

  @override
  String get shellKindTypeScript => 'TypeScript';

  @override
  String get shellKindDart => 'Dart';

  @override
  String get shellKindPython => 'Python';

  @override
  String get shellKindShell => 'Shell';

  @override
  String get shellKindPlainText => 'Texto simples';

  @override
  String get shellKindBinary => 'Binário';

  @override
  String get workspaceShowExplorer => 'Mostrar explorador';

  @override
  String get workspaceHideExplorer => 'Ocultar explorador';

  @override
  String get workspaceShowGit => 'Mostrar git';

  @override
  String get workspaceHideGit => 'Ocultar git';

  @override
  String get workspaceNoRepository =>
      'Esta pasta não está dentro de um repositório Git.';

  @override
  String get workspaceNoRepositoryWorks =>
      'Ler e editar funcionam como sempre.';

  @override
  String get workspaceNoRepositoryUnversioned => 'Nada aqui é versionado.';

  @override
  String get spacesCloseSpace => 'Fechar espaço';

  @override
  String get spacesRecentSpaces => 'ESPAÇOS RECENTES';

  @override
  String get spacesUnsavedClosing =>
      'Fechar o espaço sai da janela, e a edição que não chegou ao disco vai junto.';

  @override
  String spacesUnsavedOpening(String space) {
    return 'Abrir $space substitui o que está na tela, e a edição que não chegou ao disco vai junto.';
  }

  @override
  String get spacesSaveAndOpen => 'Salvar e abrir';

  @override
  String get spacesDiscardAndOpen => 'Descartar e abrir';

  @override
  String get spacesStay => 'Ficar neste espaço';

  @override
  String spacesUnsavedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documentos têm alterações não salvas.',
      one: '1 documento tem alterações não salvas.',
    );
    return '$_temp0';
  }

  @override
  String get spacesUnsavedClosingMany =>
      'Fechar o espaço sai da janela, e as edições que não chegaram ao disco vão junto.';

  @override
  String spacesUnsavedOpeningMany(String space) {
    return 'Abrir $space substitui o que está na tela, e as edições que não chegaram ao disco vão junto.';
  }

  @override
  String get spacesUnsavedQuitting =>
      'Fechar a janela sai do TOM, e a edição que não chegou ao disco vai junto.';

  @override
  String get spacesUnsavedQuittingMany =>
      'Fechar a janela sai do TOM, e as edições que não chegaram ao disco vão junto.';

  @override
  String get spacesSaveAllAndClose => 'Salvar todos e fechar';

  @override
  String get spacesDiscardAllAndClose => 'Descartar todos e fechar';

  @override
  String get spacesSaveAllAndOpen => 'Salvar todos e abrir';

  @override
  String get spacesDiscardAllAndOpen => 'Descartar todos e abrir';

  @override
  String spacesUnopened(String space) {
    return 'Não foi possível abrir $space — foi movido?';
  }

  @override
  String get pullRequestProposingOnto => 'Propondo para';

  @override
  String get pullRequestThisBranch => 'Esta branch';

  @override
  String pullRequestProposal(int commits, int documents) {
    String _temp0 = intl.Intl.pluralLogic(
      commits,
      locale: localeName,
      other: '$commits commits',
      one: '1 commit',
    );
    String _temp1 = intl.Intl.pluralLogic(
      documents,
      locale: localeName,
      other: '$documents documentos',
      one: '1 documento',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String pullRequestOpenOn(String host) {
    return 'Abrir no $host';
  }

  @override
  String get pullRequestPushing => 'Fazendo push…';

  @override
  String pullRequestOnBase(String base) {
    return 'Em $base — nada a propor';
  }

  @override
  String pullRequestOnBaseWhy(String base) {
    return 'Esta é a $base, a branch onde um pull request entra. Mude para outra branch para propô-la.';
  }

  @override
  String get pullRequestUnknownHost => 'origin não está em um host conhecido';

  @override
  String get pullRequestUnknownHostWhy =>
      'origin não está no GitHub, GitLab ou Bitbucket, então não há página onde abrir um pull request.';

  @override
  String get pullRequestNoRemote => 'Nenhum remoto para onde propor';

  @override
  String get pullRequestNoRemoteWhy =>
      'Este repositório não tem remoto. Um pull request é aberto no remoto em que ele seria integrado.';

  @override
  String get pullRequestDetached => 'Fora de uma branch';

  @override
  String get pullRequestDetachedWhy =>
      'O HEAD aponta para um commit, não para uma branch. Mude para uma branch para propô-la.';

  @override
  String get pullRequestNoBase => 'origin não indica branch para onde propor';

  @override
  String get pullRequestNoBaseWhy =>
      'origin não indica uma branch padrão, e não há main nem master para onde propor.';

  @override
  String get pullRequestUnreadable => 'não foi possível ler o git';

  @override
  String get pullRequestUnreadableWhy =>
      'Não foi possível ler o git aqui, então a branch é desconhecida.';

  @override
  String pullRequestReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pronto para abrir. $count commits enviados, nada falta publicar.',
      one: 'Pronto para abrir. 1 commit enviado, nada falta publicar.',
    );
    return '$_temp0';
  }

  @override
  String pullRequestUncommitted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count documentos estão sem commit. Eles ficariam fora deste pull request — faça commit deles antes.',
      one:
          '1 documento está sem commit. Ele ficaria fora deste pull request — faça commit dele antes.',
    );
    return '$_temp0';
  }

  @override
  String pullRequestUnpublished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count commits ainda não estão no remoto. Faça push antes de abrir.',
      one: '1 commit ainda não está no remoto. Faça push antes de abrir.',
    );
    return '$_temp0';
  }

  @override
  String get pullRequestUnpublishedBranch =>
      'Esta branch ainda não está no remoto. Faça push dela antes de abrir.';

  @override
  String get pullRequestUntitled =>
      'O rascunho não tem título — a primeira linha dele é um cabeçalho #.';

  @override
  String pullRequestEmpty(String base) {
    return 'Nada a propor ainda: esta branch não tem commits além de $base.';
  }

  @override
  String pullRequestNoCommitsOver(String base) {
    return 'Nenhum commit além de $base';
  }

  @override
  String get pullRequestCreate => 'Criar pull request';

  @override
  String get pullRequestCreating => 'Criando…';

  @override
  String pullRequestOpenOnInstead(String host) {
    return 'Abrir no $host em vez disso';
  }

  @override
  String pullRequestView(int number, String host) {
    return 'Ver #$number no $host';
  }

  @override
  String pullRequestAlreadyOpen(int number, String host) {
    return 'O pull request #$number está aberto no $host — foi aberto com este rascunho.';
  }

  @override
  String pullRequestNotCreatedUnreachable(String host) {
    return 'Não foi possível alcançar o $host — o pull request não foi aberto.';
  }

  @override
  String pullRequestNotCreatedRefused(String host) {
    return 'O $host recusou o token desta conta — o pull request não foi aberto.';
  }

  @override
  String pullRequestNotCreated(String host) {
    return 'O $host não abriu o pull request.';
  }

  @override
  String get pullRequestReading => 'Lendo a branch em relação à base…';

  @override
  String get pullRequestFailed =>
      'O git não conseguiu ler esta branch em relação à base — tente outra base.';

  @override
  String get pullRequestCounting => 'Contando o que a branch fez…';

  @override
  String pullRequestMinutes(int count) {
    return '$count min';
  }

  @override
  String get pullRequestToReview => 'para revisar';

  @override
  String get pullRequestWords => 'Palavras';

  @override
  String get pullRequestBlocks => 'Blocos';

  @override
  String get pullRequestDocuments => 'Documentos';

  @override
  String get pullRequestCommits => 'Commits';

  @override
  String get pullRequestFolders => 'Pastas';

  @override
  String get pullRequestMostChanged => 'Mais alterado';

  @override
  String pullRequestModified(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modificados',
      one: '1 modificado',
    );
    return '$_temp0';
  }

  @override
  String pullRequestAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adicionados',
      one: '1 adicionado',
    );
    return '$_temp0';
  }

  @override
  String pullRequestDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count excluídos',
      one: '1 excluído',
    );
    return '$_temp0';
  }

  @override
  String pullRequestCommitsSince(int count, String when) {
    return '$count · o primeiro $when';
  }

  @override
  String pullRequestParagraphs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parágrafos',
      one: '1 parágrafo',
    );
    return '$_temp0';
  }

  @override
  String pullRequestHeadings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cabeçalhos',
      one: '1 cabeçalho',
    );
    return '$_temp0';
  }

  @override
  String pullRequestLists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listas',
      one: '1 lista',
    );
    return '$_temp0';
  }

  @override
  String pullRequestTables(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tabelas',
      one: '1 tabela',
    );
    return '$_temp0';
  }

  @override
  String pullRequestCodeBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocos de código',
      one: '1 bloco de código',
    );
    return '$_temp0';
  }

  @override
  String pullRequestQuotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citações',
      one: '1 citação',
    );
    return '$_temp0';
  }

  @override
  String pullRequestRules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linhas horizontais',
      one: '1 linha horizontal',
    );
    return '$_temp0';
  }

  @override
  String pullRequestHtmlBlocks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocos HTML',
      one: '1 bloco HTML',
    );
    return '$_temp0';
  }

  @override
  String changesToResolve(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documentos para resolver',
      one: '1 documento para resolver',
    );
    return '$_temp0';
  }

  @override
  String changesStagedOf(int staged, int total) {
    return '$staged de $total no stage';
  }

  @override
  String get changesNothingChanged => 'Nada mudou desde o último commit.';

  @override
  String get changesStagedSection => 'NO STAGE';

  @override
  String get changesChangesSection => 'ALTERAÇÕES';

  @override
  String get changesUnstageAll => 'Remover tudo do stage';

  @override
  String get changesStageAll => 'Adicionar tudo ao stage';

  @override
  String get changesMergeInProgress =>
      'Há um merge em andamento — resolva-o primeiro.';

  @override
  String get changesGitCouldNot => 'O git não conseguiu fazer isso.';

  @override
  String get changesNotOnABranch =>
      'Fora de uma branch — mude para uma para fazer commit.';

  @override
  String get changesNoCommitYet => 'Ainda não há commit para o qual voltar.';

  @override
  String changesAlreadyCommitted(String name) {
    return '$name está no último commit, então não foi excluído. A lista foi lida de novo.';
  }

  @override
  String changesStillHoldsMarker(String name) {
    return '$name ainda tem um marcador de conflito — resolva-o e depois adicione ao stage.';
  }

  @override
  String changesStillHoldMarkers(int count) {
    return '$count documentos ainda têm um marcador de conflito — resolva-os e depois adicione ao stage.';
  }

  @override
  String get changesMenuTooltip => 'Menu do git';

  @override
  String get changesOpenInTerminal => 'Abrir no terminal';

  @override
  String get changesDiscardAll => 'Descartar todas as alterações';

  @override
  String get changesDiscardAllQuestion => 'Descartar todas as alterações?';

  @override
  String changesDiscardAllGoesBack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documentos voltam ao último commit.',
      one: '1 documento volta ao último commit.',
    );
    return '$_temp0';
  }

  @override
  String get changesDiscardAllKeepsNew =>
      'Arquivos novos são mantidos, não rastreados.';

  @override
  String get changesKeepTheChanges => 'Manter as alterações';

  @override
  String get changesDiscardChanges => 'Descartar alterações';

  @override
  String changesDiscardChangesTo(String name) {
    return 'Descartar alterações em $name?';
  }

  @override
  String get changesDiscardKeepsStaged =>
      'Tudo o que não está no stage se perde. O que já está no stage fica.';

  @override
  String get changesDiscardSinceCommit =>
      'Tudo o que mudou desde o último commit se perde, no stage ou não.';

  @override
  String get changesDelete => 'Excluir';

  @override
  String changesDeleteFile(String name) {
    return 'Excluir $name?';
  }

  @override
  String get changesDeleteNeverCommitted =>
      'Nunca entrou em um commit, então não tem como voltar.';

  @override
  String get changesDiscardCancel => 'Cancelar';

  @override
  String get changesSummaryHint => 'Resumo';

  @override
  String get changesDescriptionHint => 'Descrição (opcional)';

  @override
  String get changesCommit => 'Commit';

  @override
  String changesCommitTo(String branch) {
    return 'Commit em $branch';
  }

  @override
  String get changesCommitting => 'Fazendo commit…';

  @override
  String changesUpToDate(String upstream) {
    return 'Em dia com $upstream';
  }

  @override
  String changesBehind(int count, String upstream) {
    return '$count atrás de $upstream';
  }

  @override
  String changesAhead(int count, String upstream) {
    return '$count à frente de $upstream';
  }

  @override
  String changesAheadAndBehind(int ahead, int behind, String upstream) {
    return '$ahead à frente, $behind atrás de $upstream';
  }

  @override
  String get changesLinkNoNetwork => 'Sem rede';

  @override
  String get changesLinkCredentialsRefused => 'O git recusou as credenciais';

  @override
  String get changesLinkNoRemote => 'Nenhum remoto configurado';

  @override
  String get changesLinkTimedOut => 'O remoto não respondeu';

  @override
  String get changesFetching => 'Fazendo fetch…';

  @override
  String get changesPulling => 'Fazendo pull…';

  @override
  String get changesPushing => 'Fazendo push…';

  @override
  String get remoteTheRemote => 'o remoto';

  @override
  String get remoteAbortThePull => 'Abortar o pull';

  @override
  String get remoteTryAgain => 'Tentar de novo';

  @override
  String get remoteAbortQuestion => 'Abortar o pull?';

  @override
  String get remoteAbortGoesBack => 'O espaço volta ao que era antes do pull.';

  @override
  String get remoteAbortStaysFetched =>
      'O que chegou do remoto continua baixado.';

  @override
  String get remoteKeepTheConflict => 'Manter o conflito';

  @override
  String remoteAlreadyLevel(String upstream) {
    return 'Já em dia com $upstream — nada chegou.';
  }

  @override
  String remotePulled(int count, String upstream) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commits chegaram',
      one: '1 commit chegou',
    );
    return '$_temp0 de $upstream com o pull.';
  }

  @override
  String remoteStillToPublish(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ainda falta publicar $count dos seus.',
      one: 'Ainda falta publicar 1 dos seus.',
    );
    return '$_temp0';
  }

  @override
  String get remoteBranchProtected =>
      'O remoto recusou esta branch. Nada foi publicado, e nenhum commit seu foi perdido.';

  @override
  String remoteCommitted(String message) {
    return 'Commit feito: “$message”.';
  }

  @override
  String remoteCommittedWaiting(String message, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commits esperando push.',
      one: '1 commit esperando push.',
    );
    return 'Commit feito: “$message”. $_temp0';
  }

  @override
  String remotePublished(int count, String upstream) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commits publicados',
      one: '1 commit publicado',
    );
    return '$_temp0 em $upstream.';
  }

  @override
  String remotePublishedBranch(String upstream) {
    return 'Publicado em $upstream.';
  }

  @override
  String remoteStopped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documentos em conflito.',
      one: '1 documento em conflito.',
    );
    return 'O pull parou: $_temp0 Nenhum commit seu foi perdido.';
  }

  @override
  String remoteStoppedShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documentos em conflito.',
      one: '1 documento em conflito.',
    );
    return 'O pull parou: $_temp0';
  }

  @override
  String remoteRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commits',
      one: '1 commit',
    );
    return 'Alguém fez push de $_temp0 antes. Faça pull deles e depois push de novo — nenhum commit seu foi perdido.';
  }

  @override
  String get remoteRejectedUncounted =>
      'Alguém fez push antes. Faça pull e depois push de novo — nenhum commit seu foi perdido.';

  @override
  String get remoteNotAccepted => 'O remoto não aceitou esta máquina.';

  @override
  String get remoteCouldNotReach => 'O git não conseguiu alcançar o remoto.';

  @override
  String get remoteRefusedFetch => 'O git recusou o fetch.';

  @override
  String get remoteRefusedPull => 'O git recusou o pull.';

  @override
  String get remoteRefusedPush => 'O git recusou o push.';

  @override
  String get remoteCostFetch => 'Nada chegou.';

  @override
  String get remoteCostPull => 'Nada mudou aqui.';

  @override
  String get remoteCostPush =>
      'Nada foi publicado, e nenhum commit seu foi perdido.';

  @override
  String remoteWouldOverwriteOne(String name) {
    return 'O git recusou o pull: ele sobrescreveria as alterações sem commit em $name. Nada mudou aqui — faça o commit delas e tente de novo.';
  }

  @override
  String remoteWouldOverwriteMany(int count) {
    return 'O git recusou o pull: ele sobrescreveria as alterações sem commit em $count arquivos. Nada mudou aqui — faça o commit delas e tente de novo.';
  }

  @override
  String get remoteWouldOverwriteUncounted =>
      'O git recusou o pull: ele sobrescreveria alterações que não têm commit. Nada mudou aqui — faça o commit delas e tente de novo.';

  @override
  String get compareToLastCommit => 'Comparado ao último commit';

  @override
  String compareTo(String base) {
    return 'Comparado a $base';
  }

  @override
  String get compareDiff => 'Diff';

  @override
  String exportExporting(String name) {
    return 'Exportando $name…';
  }

  @override
  String exportExported(String name, String folder) {
    return '$name exportado para $folder.';
  }

  @override
  String get exportReveal => 'Mostrar';

  @override
  String exportFailed(String name, String reason) {
    return 'Não foi possível exportar $name: $reason. Nada foi gravado.';
  }

  @override
  String get exportCannotWrite => 'essa pasta não aceitou o arquivo';

  @override
  String get exportTooLarge => 'há algo nele mais alto que uma página';

  @override
  String exportUnsupported(String format) {
    return 'o TOM não tem exportador de $format';
  }

  @override
  String get exportUnreadable => 'não foi possível ler o documento';

  @override
  String get historyScoped => 'restrito a este arquivo, não ao repositório';

  @override
  String get historyOpenADocument =>
      'Abra um documento para ver o que o alterou.';

  @override
  String get historyNoRecord => 'O git ainda não tem registro deste arquivo.';

  @override
  String get historyUnreadable =>
      'O git não conseguiu ler o histórico deste arquivo.';

  @override
  String get historyNoMessage => '(sem mensagem)';

  @override
  String get branchesUnreadable =>
      'O git não conseguiu dizer quais branches existem.';

  @override
  String get branchesFilterHint => 'Filtrar branches';

  @override
  String get branchesNoneByThatName => 'Nenhuma branch com esse nome.';

  @override
  String get branchesRefused => 'O git recusou isso. Nada mudou.';

  @override
  String get branchesCreateEllipsis => 'Criar branch…';

  @override
  String get branchesNewNameHint => 'Nome da nova branch';

  @override
  String get branchesNameNotAccepted => 'Não é um nome que o git aceita';

  @override
  String get branchesNameTaken => 'Já existe uma branch com esse nome';

  @override
  String branchesStartsFrom(String branch) {
    return 'Parte de $branch e muda para ela.';
  }

  @override
  String get branchesStartsFromHere =>
      'Parte de onde você está e muda para ela.';

  @override
  String get branchesCreate => 'Criar branch';

  @override
  String get branchesBackToTheList => 'Voltar à lista';

  @override
  String branchesSwitchingReplaces(String branch) {
    return 'Mudar para $branch o substituiria pela versão daquela branch.';
  }

  @override
  String get branchesSaveAndSwitch => 'Salvar e mudar';

  @override
  String get branchesDiscardAndSwitch => 'Descartar e mudar';

  @override
  String get branchesStayOnThisBranch => 'Ficar nesta branch';

  @override
  String get editorUndo => 'Desfazer';

  @override
  String get editorRedo => 'Refazer';

  @override
  String get editorHeading => 'Título';

  @override
  String get editorBold => 'Negrito';

  @override
  String get editorItalic => 'Itálico';

  @override
  String get editorStrikethrough => 'Tachado';

  @override
  String get editorList => 'Lista';

  @override
  String get editorOrderedList => 'Lista numerada';

  @override
  String get editorTaskList => 'Lista de tarefas';

  @override
  String get editorQuote => 'Citação';

  @override
  String get editorCode => 'Código';

  @override
  String get editorTable => 'Tabela';

  @override
  String get editorRule => 'Linha horizontal';

  @override
  String get editorLink => 'Link';

  @override
  String get editorImage => 'Imagem';

  @override
  String get editorFootnote => 'Nota de rodapé';

  @override
  String get editorAlert => 'Alerta';

  @override
  String get editorMoreFormatting => 'Mais formatação';

  @override
  String get editorCloseTabDiscards =>
      'Fechar a aba descarta a edição que ainda não chegou ao disco.';

  @override
  String get editorCloseTabDiskKept => 'O arquivo no disco continua como está.';

  @override
  String get editorKeepTabOpen => 'Manter a aba aberta';

  @override
  String get editorCloseTabTooltip => 'Fechar';

  @override
  String get editorExportAsPdf => 'Exportar como PDF…';

  @override
  String get editorExportAsHtml => 'Exportar como HTML…';

  @override
  String get editorCloseTab => 'Fechar aba';

  @override
  String get editorTabDeleted => '(excluído)';

  @override
  String get editorBinaryFile =>
      'Um arquivo binário — não é mostrado como texto.';

  @override
  String get editorCompletionHint =>
      '↑↓ para escolher · Enter para inserir · Esc para fechar';

  @override
  String get previewRemoved => 'Removido';

  @override
  String previewNoDocumentCalled(String target) {
    return 'Nenhum documento chamado $target.';
  }

  @override
  String get previewCreateIt => 'Criar';

  @override
  String get previewDocumentEmpty => 'Este documento está vazio.';

  @override
  String get searchThisFile => 'Este arquivo';

  @override
  String get searchWholeSpace => 'Espaço inteiro';

  @override
  String searchDocumentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count documentos',
      one: '1 documento',
    );
    return '$_temp0';
  }

  @override
  String get searchReadingTheSpace => 'Lendo o espaço…';

  @override
  String get searchNoDocumentSaysThat => 'Nenhum documento diz isso.';

  @override
  String get searchIndexCorrupted =>
      'Não foi possível montar o índice — reabra o espaço para tentar de novo.';

  @override
  String get searchFailed => 'Não foi possível pesquisar neste espaço.';

  @override
  String get searchOpenADocument => 'Abra um documento para pesquisar nele.';

  @override
  String get searchTypeToSearch => 'Digite para pesquisar neste documento.';

  @override
  String searchNothingInDocument(String name) {
    return 'Nada em $name diz isso.';
  }

  @override
  String searchOccurrenceCount(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ocorrências em $name',
      one: '1 ocorrência em $name',
    );
    return '$_temp0';
  }

  @override
  String get searchReplaceAll => 'Substituir tudo';

  @override
  String get searchReplaceThisOne => 'Substituir esta';

  @override
  String get searchSkipThisOne => 'Pular esta';

  @override
  String get searchReplaceWith => 'Substituir por';

  @override
  String get searchHint => 'Pesquisar';

  @override
  String get searchClear => 'Limpar a pesquisa';

  @override
  String searchHideReplace(String keys) {
    return 'Ocultar substituir ($keys)';
  }

  @override
  String searchShowReplace(String keys) {
    return 'Substituir ($keys)';
  }

  @override
  String get fileTreeSearchCaption => 'PESQUISA';

  @override
  String get fileTreeExplorerCaption => 'EXPLORADOR';

  @override
  String get fileTreeNewDocument => 'Novo documento';

  @override
  String get fileTreeMenu => 'Menu do explorador';

  @override
  String get fileTreeNewFolder => 'Nova pasta';

  @override
  String get fileTreeCollapseAll => 'Recolher tudo';

  @override
  String get fileTreeReading => 'Lendo a pasta…';

  @override
  String get fileTreeFolderMissing => 'Esta pasta não está mais lá.';

  @override
  String get fileTreeAccessDenied =>
      'O TOM não tem permissão para ler esta pasta.';

  @override
  String get fileTreeUnreadable => 'Não foi possível ler esta pasta.';

  @override
  String get fileTreeEmpty => 'Esta pasta ainda está vazia.';

  @override
  String get accountTooltip => 'Conta';

  @override
  String get accountTooltipUnread => 'Conta — ainda não lida';

  @override
  String get accountCommitsAs => 'FAZ COMMIT COMO';

  @override
  String get accountNameNotSet => 'Não definido';

  @override
  String get accountIdentityMissing =>
      'o git pede um nome e um e-mail primeiro';

  @override
  String get accountGithub => 'GITHUB';

  @override
  String get accountViaGh => 'pelo gh';

  @override
  String get accountViaGit => 'pelo git';

  @override
  String get accountViaSsh => 'pelo SSH';

  @override
  String get accountLoginViaGh =>
      'O login do GitHub deste computador, pelo gh — o TOM não guarda cópia.';

  @override
  String get accountLoginViaGit =>
      'O login do GitHub deste computador, pelo git — o TOM não guarda cópia.';

  @override
  String get accountLoginViaSsh =>
      'O login do GitHub deste computador, pelo SSH — o TOM não guarda cópia.';

  @override
  String get accountNoCredentials =>
      'Nenhuma credencial do GitHub neste computador';

  @override
  String get accountNoCredentialsHint =>
      'O TOM usa o que o git e o gh já têm — rode gh auth login, ou faça push uma vez por HTTPS.';

  @override
  String get accountThisRepository => 'ESTE REPOSITÓRIO';

  @override
  String get accountOpenRepository => 'Abrir no GitHub';

  @override
  String get accountColumnRead => 'LER';

  @override
  String get accountColumnPullRequest => 'PR';

  @override
  String get accountColumnPush => 'PUSH';

  @override
  String get accountColumnMerge => 'MERGE';

  @override
  String get accountColumnAdmin => 'ADMIN';

  @override
  String get accountAccessUnknown =>
      'O que você pode fazer aqui aparece quando o git ou o gh alcançarem o GitHub.';

  @override
  String get accountAccessSsh =>
      'O SSH diz quem você é, não o que você pode fazer aqui.';

  @override
  String get accountAsking => 'Perguntando ao git e ao gh quem você é…';

  @override
  String get accountAccessPending => 'Aparece assim que a resposta chegar.';

  @override
  String get accountCan => 'Sim';

  @override
  String get accountCannot => 'Não';

  @override
  String get accountUnknown => 'Desconhecido';

  @override
  String get panelCommands => 'Comandos';

  @override
  String commandsThisSession(int count) {
    return '$count nesta sessão';
  }

  @override
  String get commandsNoneYet => 'Nenhum comando rodou ainda.';

  @override
  String get commandsCopy => 'Copiar o comando';

  @override
  String get commandsPrintedNothing => 'Não imprimiu nada.';

  @override
  String commandsExit(int code) {
    return 'saída $code';
  }

  @override
  String get commandsUnfinished => 'não terminou';

  @override
  String get commandsDidNotRun => 'não rodou';

  @override
  String commandsMilliseconds(int value) {
    return '$value ms';
  }

  @override
  String commandsSeconds(double value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString s';
  }

  @override
  String commandsMinutes(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String get workspaceShowBottom => 'Mostrar o painel inferior';

  @override
  String get workspaceHideBottom => 'Ocultar o painel inferior';

  @override
  String get workspaceClosePanel => 'Fechar o painel';

  @override
  String get remoteShowTheCommand => 'Mostrar o comando';

  @override
  String get panelTerminal => 'Terminal';

  @override
  String terminalPlace(String shell, String folder) {
    return '$shell · $folder';
  }

  @override
  String get terminalFailed => 'O shell não iniciou.';

  @override
  String terminalExited(int code) {
    return 'O shell terminou com $code. Tecle algo para abrir outro.';
  }

  @override
  String get preferencesGitCommands => 'COMANDOS DO GIT';

  @override
  String get preferencesGitAutomatic => 'Automático';

  @override
  String get preferencesGitSemi => 'Semi';

  @override
  String get preferencesGitManual => 'Manual';

  @override
  String get preferencesGitAutomaticWhy =>
      'Cada comando roda assim que é pedido; o painel de comandos só guarda o registro.';

  @override
  String get preferencesGitSemiWhy =>
      'Um comando espera sua aprovação, a menos que o git-approvals.json o permita.';

  @override
  String get preferencesGitManualWhy =>
      'Todo comando espera sua aprovação, inclusive as leituras.';

  @override
  String get preferencesOpenApprovals => 'Abrir git-approvals.json';

  @override
  String get gitModeAutomatic => 'Automático';

  @override
  String get gitModeSemi => 'Semiautomático';

  @override
  String get gitModeManual => 'Manual';

  @override
  String commandsWaitingCount(String mode, int count) {
    return '$mode · $count aguardando';
  }

  @override
  String get commandsApproveRun => 'Executar';

  @override
  String get commandsApproveAlways => 'Permitir sempre';

  @override
  String get commandsApproveDeny => 'Negar';

  @override
  String get commandsWaitsForAbove => 'espera o de cima';

  @override
  String get commandsAllowed => 'permitido';

  @override
  String get commandsDenied => 'negado';

  @override
  String get commandsCancelled => 'cancelado';

  @override
  String commandsPlanHead(String action, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comandos',
      one: '1 comando',
    );
    return '$action · $_temp0';
  }

  @override
  String commandsPlanStopped(String action, int ran, int total) {
    return '$action · interrompido · $ran de $total rodaram';
  }

  @override
  String get approvalsSwitchTitle => 'Mudar para Semiautomático?';

  @override
  String get approvalsSwitchBody =>
      'Permitir sempre grava no git-approvals.json, e o modo Manual não lê esse arquivo. No Semiautomático só este comando fica permitido; todos os outros continuam false.';

  @override
  String get approvalsStayManual => 'Ficar no Manual';

  @override
  String get approvalsSwitch => 'Mudar para Semiautomático';

  @override
  String get changesWaitingForApproval => 'Aguardando aprovação';

  @override
  String get changesOutOfDate => 'Desatualizado: uma leitura foi negada.';

  @override
  String get changesOutOfDateReload => 'Recarregar';

  @override
  String get commandAction_openSpace => 'Abrindo o espaço';

  @override
  String get commandAction_cloneRepository => 'Clonando o repositório';

  @override
  String get commandAction_readRecentBranch => 'Lendo a branch';

  @override
  String get commandAction_readRepository => 'Lendo o repositório';

  @override
  String get commandAction_readBranches => 'Lendo as branches';

  @override
  String get commandAction_readDiffBase => 'Lendo contra o que o diff compara';

  @override
  String get commandAction_readHistory => 'Lendo o histórico';

  @override
  String get commandAction_readVersion => 'Lendo uma versão';

  @override
  String get commandAction_stage => 'Preparar (stage)';

  @override
  String get commandAction_unstage => 'Desfazer o stage';

  @override
  String get commandAction_commit => 'Commit';

  @override
  String get commandAction_discard => 'Descartar alterações';

  @override
  String get commandAction_discardAll => 'Descartar todas as alterações';

  @override
  String get commandAction_fetch => 'Fetch';

  @override
  String get commandAction_pull => 'Pull';

  @override
  String get commandAction_push => 'Push';

  @override
  String get commandAction_abortPull => 'Cancelar o pull';

  @override
  String get commandAction_switchBranch => 'Trocar de branch';

  @override
  String get commandAction_createBranch => 'Criar uma branch';

  @override
  String get commandAction_readPullRequest => 'Lendo o pull request';

  @override
  String get commandAction_createPullRequest => 'Abrir um pull request';

  @override
  String get commandAction_readAccount => 'Lendo a conta';

  @override
  String get commandAction_chooseAccount => 'Escolher a conta';
}
