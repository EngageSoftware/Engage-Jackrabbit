// <copyright file="PublicAPIAttribute.cs" company="JetBrains s.r.o.">
// Copyright 2007-2012 JetBrains s.r.o.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>

namespace JetBrains.Annotations
{
    using System;
    using System.Diagnostics.CodeAnalysis;

    /// <summary>This attribute is intended to mark publicly available API which should not be removed and so is treated as used.</summary>
    [SuppressMessage("Microsoft.Design", "CA1019:DefineAccessorsForAttributeArguments", Justification = "Jetbrains code"), SuppressMessage("Microsoft.Design", "CA1018:MarkAttributesWithAttributeUsage", Justification = "Jetbrains code"), SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "API", Justification = "Jetbrains code")]
    [MeansImplicitUse]
    public sealed class PublicAPIAttribute : Attribute
    {
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code")]
        public PublicAPIAttribute()
        {
        }

        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code"), SuppressMessage("Microsoft.Usage", "CA1801:ReviewUnusedParameters", MessageId = "comment", Justification = "Jetbrains code")]
        public PublicAPIAttribute(string comment)
        {
        }
    }
}