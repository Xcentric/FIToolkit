unit FIToolkit.Runner.Consts;

interface

const

  { Common consts }

  CHR_TASK_OUTPUT_FILENAME_PARTS_DELIM = Char('_');

  INT_SPIN_WAIT_ITERATIONS = 1000;

  { FixInsight output file waiting }

  INT_FIOFILE_WAIT_CHECK_INTERVAL = 1000;
  INT_FIOFILE_WAIT_TIMEOUT        = 5 * INT_FIOFILE_WAIT_CHECK_INTERVAL;

resourcestring

  { Exceptions }

  RSCreateProcessError = 'Не удалось создать процесс.';
  RSNonZeroExitCode = 'Запущенный процесс завершился с кодом %d. Командная строка: %s';
  RSSomeTasksFailed = 'Одна или более задач по обработке проектов завершились неудачей.';

implementation

end.
