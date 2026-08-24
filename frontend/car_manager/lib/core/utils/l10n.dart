import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

/// Scurtatura pentru traduceri: `tr(context).save` in loc de
/// `AppLocalizations.of(context).save`.
///
/// Functioneaza oriunde exista un `context` — inclusiv in metodele unei
/// clase `State`, unde `context` e proprietate a clasei.
AppLocalizations tr(BuildContext context) => AppLocalizations.of(context);
