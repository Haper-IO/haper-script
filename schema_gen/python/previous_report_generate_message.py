from typing import Any, List, TypeVar, Callable, Type, cast


T = TypeVar("T")


def from_str(x: Any) -> str:
    assert isinstance(x, str)
    return x


def from_float(x: Any) -> float:
    assert isinstance(x, (float, int)) and not isinstance(x, bool)
    return float(x)


def to_float(x: Any) -> float:
    assert isinstance(x, (int, float))
    return x


def from_list(f: Callable[[Any], T], x: Any) -> List[T]:
    assert isinstance(x, list)
    return [f(y) for y in x]


def to_class(c: Type[T], x: Any) -> dict:
    assert isinstance(x, c)
    return cast(Any, x).to_dict()


class TaskByAccount:
    account_id: str
    number_of_email: float

    def __init__(self, account_id: str, number_of_email: float) -> None:
        self.account_id = account_id
        self.number_of_email = number_of_email

    @staticmethod
    def from_dict(obj: Any) -> 'TaskByAccount':
        assert isinstance(obj, dict)
        account_id = from_str(obj.get("account_id"))
        number_of_email = from_float(obj.get("number_of_email"))
        return TaskByAccount(account_id, number_of_email)

    def to_dict(self) -> dict:
        result: dict = {}
        result["account_id"] = from_str(self.account_id)
        result["number_of_email"] = to_float(self.number_of_email)
        return result


class PreviousReportGenerateMessage:
    report_id: str
    task_info: List[TaskByAccount]
    user_id: str

    def __init__(self, report_id: str, task_info: List[TaskByAccount], user_id: str) -> None:
        self.report_id = report_id
        self.task_info = task_info
        self.user_id = user_id

    @staticmethod
    def from_dict(obj: Any) -> 'PreviousReportGenerateMessage':
        assert isinstance(obj, dict)
        report_id = from_str(obj.get("report_id"))
        task_info = from_list(TaskByAccount.from_dict, obj.get("task_info"))
        user_id = from_str(obj.get("user_id"))
        return PreviousReportGenerateMessage(report_id, task_info, user_id)

    def to_dict(self) -> dict:
        result: dict = {}
        result["report_id"] = from_str(self.report_id)
        result["task_info"] = from_list(lambda x: to_class(TaskByAccount, x), self.task_info)
        result["user_id"] = from_str(self.user_id)
        return result


def previous_report_generate_message_from_dict(s: Any) -> PreviousReportGenerateMessage:
    return PreviousReportGenerateMessage.from_dict(s)


def previous_report_generate_message_to_dict(x: PreviousReportGenerateMessage) -> Any:
    return to_class(PreviousReportGenerateMessage, x)
