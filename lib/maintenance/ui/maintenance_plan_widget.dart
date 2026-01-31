import 'package:flutter/material.dart';
import 'package:part_tracker/maintenance/domain/entities/maintenance_plan.dart';

class MaintenancePlanWidget extends StatelessWidget {
  const MaintenancePlanWidget(
      {super.key, required this.plan, required this.onTap});
  final MaintenancePlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(child: Text("id : ${plan.id}")),
              Flexible(flex: 2, child: Text(plan.title)),
              Flexible(
                flex: 10,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4 ,
                  child: Text(
                    plan.description,
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
